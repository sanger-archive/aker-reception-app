(function($, undefined) {
  function DataTableSchemaValidation(node, params) {
    this._node = $(node);
    this.params = params;
    this._loadedSchema = null;
    /**
     * An object of verified HMDMC numbers, e.g.:
     * { '12/500': false, '12/200': true }
     */
    this.verifiedHMDMC = {};
    this.loadSchema().then($.proxy(this.attachHandlers, this));
  }

  var proto = DataTableSchemaValidation.prototype;

  proto.loadSchema = function() {
    return $.ajax({url: this.params.material_schema_url,
      success: $.proxy(function(json) {
        this._loadedSchema = json;
        return this._loadedSchema;
    }, this)});
  };

  proto.dataForNode = function(node) {
    return {
      errors: {},
      labwareIndex: $(node).parents('tr').data('labwareIndex'),
      address: $(node).parents('tr').data('address')
    };
  };

  proto.validationWarning = function(node, attr, msg) {
    var data = this.dataForNode(node);
    if (attr) {
      if (!data.warnings) {
        data.warnings = {}
      }
      data.warnings[attr] = msg;
    }
    this.defer.resolve({eventName: 'psd.schema.warning', node: node, data: {
      node: node,
      messages: [ data ]
    }});
  };



  proto.validationError = function(node, attr, msg) {
    var data = this.dataForNode(node);
    if (attr) {
      data.errors[attr] = msg;
    }
    this.defer.resolve({eventName: 'psd.schema.error', node: node, data: {
      node: node,
      messages: [ data ]
    }});
  };

  Array.prototype.indexOfCaseInsensitive = function(item) {
    item = item.toUpperCase();
    for (var index = 0; index < this.length; ++index) {
      if (item===this[index].toUpperCase()) {
        return index;
      }
    }
    return -1;
  }

  proto.column = function(labwareId, fieldName) {
    return $('input').filter((pos, input) => { 
      var id = $(input).attr('id');
      return (id && id.match("fieldName\\["+fieldName+"\\]") && 
        id.match("labware\\["+labwareId+"\\]"));
    }).toArray().reduce($.proxy(function(memo, input) {
      var data = this.positionDataForInput(input)
      memo[data.address] = input
      return memo
    }, this), {});
  };

  proto.positionDataForInput = function(input) {
    var id = $(input).attr('id')
    return {
      id: id,
      labwareId: id.match(/^labware\[(\d*)\]/)[1],
      address: id.match(/address\[([\w:]*)\]/)[1],
      fieldName: id.match(/fieldName\[(\w*)\]/)[1]
    };
  };

  proto.schemaChecks = {
    failsDataValueDuplicatedSamePlate: function(schema, msg) {
      if (!schema.unique_value || !(msg.value && msg.value.trim())) {
        return false;
      }

      var data = this.positionDataForInput(msg.node)
      var column = this.column(data.labwareId, data.fieldName)

      delete column[data.address]

      var keys = Object.keys(column)
      var values = Object.values(column).map((input, pos) => { return $(input).val()})
      var value = $(msg.node).val()
      var pos = $.inArray(value, values)
      if (pos >= 0) {
        msg.duplicatedAddress = keys[pos]
        return true
      }
      return false
    },
    // Fails if the field is required and the msg value is missing or all whitespace.
    // Returns true if it fails.
    failsDataValueRequired: function(schema, msg) {
      return (schema.required && !(msg.value && msg.value.trim()));
    },
    // Fails if the field has an enum, the msg value is specified and not all whitespace,
    // but it is not in the enum (case insensitive).
    // Returns true if it fails.
    failsDataValueAllowed: function(schema, msg) {
      if (!schema.enum || !msg.value) {
        return false;
      }
      var v = msg.value.trim();
      if (!v) {
        return false;
      }
      // True (fail) if the value is given but unmatched
      return (schema.enum.indexOfCaseInsensitive(v) < 0);
    },
  };

  proto.warnSchemaCheck = function(schema, msg, failFunct, textFunct) {
    // 
    if (failFunct.call(this, schema, msg)) {
      this.validationWarning(msg.node, msg.name, textFunct(schema, msg));
      return true;
    }
    return false;
  };  

  proto.failSchemaCheck = function(schema, msg, failFunct, textFunct) {
    if (failFunct(schema, msg)) {
      this.validationError(msg.node, msg.name, textFunct(schema, msg));
      return true;
    }
    return false;
  };

  proto.hmdmcAjaxSuccess = function(hmdmcField, hmdmcResponseJson) {
    if (typeof hmdmcResponseJson.valid !== 'undefined') {
      // We cache that the HMDMC number is valid, so next time we won't repeat the same request
      this.verifiedHMDMC[hmdmcField.value] = hmdmcResponseJson.valid;
    }
    if (!!hmdmcResponseJson.valid) {
      // If the service says its valid, we can apply the schema validation
        $(hmdmcField.node).trigger('psd.schema.validation', {
          node: hmdmcField.node,
          name: hmdmcField.name,
          value: hmdmcField.value
        });
    } else {
      // If it is not valid, we display the error sent back from the server
      this.validationError(hmdmcField.node, hmdmcField.name, hmdmcResponseJson.error_message || 'Unspecified HDMMC problem');
    }
  };

  /**
   * Fails if the HMDMC number is invalid
   * Returns true if it fails.
   */
  proto.hmdmcCheck = function(fieldProperties, hmdmcField) {
    // Only validate the HMDMC number if there is one
    if (hmdmcField.value) {
      var hmdmcPattern = new RegExp('^[0-9]{2}\/[0-9]{3,4}$');

      // First validate that the HMDMC field is in the correct format
      if (hmdmcPattern.test(hmdmcField.value)) {
        var hmdmcNumberError = "The HMDMC number is invalid."
        // If the HMDMC number has already been checked
        if (hmdmcField.value in this.verifiedHMDMC) {
          // ... and is verified
          if (!this.verifiedHMDMC[hmdmcField.value]) {
            this.validationError(hmdmcField.node, hmdmcField.name, hmdmcNumberError);
            return true;
          }
        } else {
          // We need to check the HMDMC number and store the result
          return $.ajax({
            url: "/reception/hmdmc",
            method: "GET",
            data: { hmdmc: hmdmcField.value.replace("/", "_") },
            success: $.proxy(this.hmdmcAjaxSuccess, this, hmdmcField)
          });
        }
      } else {
        var hmdmcFormatError = "The HMDMC number should be in the format ##/####."
        this.validationError(hmdmcField.node, hmdmcField.name, hmdmcFormatError);
        return true;
      }
    }
    // HMDMC is optional
    return false;
  }

  /**
   * Perform validation on the field and set the message if failed
   */
  proto.validate = function(e, htmlField) {
    this.defer = new $.Deferred();
    // Get the properties of the field from the schema
    if (this._loadedSchema.properties['hmdmc']) {
      this._loadedSchema.properties['hmdmc']['required'] = false;
    }
    var fieldProperties = this._loadedSchema.properties[htmlField.name];

    var failed = false;
    if (fieldProperties) {
      warned = this.warnSchemaCheck(fieldProperties,
        htmlField,
        this.schemaChecks.failsDataValueDuplicatedSamePlate,
        function(fieldProperties, htmlField) {
          return 'The field ' + htmlField.name + ' has a value duplicated within the same plate at address ' + htmlField.duplicatedAddress
        });

      failed = (
        // HMDMC is not required but needs to validated if present
        (htmlField.name == 'hmdmc' && this.hmdmcCheck(fieldProperties, htmlField))
        // Check for required fields
        || this.failSchemaCheck(fieldProperties,
            htmlField,
            this.schemaChecks.failsDataValueRequired,
            function(fieldProperties, htmlField) {
              return 'The field ' + htmlField.name + ' is required'
            })
        // Check that fields are allowed
        || this.failSchemaCheck(fieldProperties,
            htmlField,
            this.schemaChecks.failsDataValueAllowed,
            function(fieldProperties, htmlField) {
              return 'This field should have any of these values ['
                + fieldProperties.enum.join(',') + ']';
            })
      );
    }

    // If the schema checks fail, they will update the errorCells.
    // If they don't fail, we should update them in case they have out of date errors.
    var node = htmlField.node;
    if (!failed && !warned) {
      this.defer.resolve({ eventName: 'psd.schema.success', node: node, data: { node: node } });
    }

    return this.defer;
  };

  proto.triggerEvents = function() {
    var dataEvents = Array.from(arguments);
    var reducedEvents = dataEvents.reduce((memo, dataEvent) => { 
      if (!memo[dataEvent.eventName]) {
        memo[dataEvent.eventName] = [];
      }
      memo[dataEvent.eventName].push(dataEvent.data);
      return memo;
    }, {})
    for (var key in reducedEvents) {
      $(dataEvents[0].node).trigger(key, reducedEvents[key])
    }
    //return dataEvents.forEach((dataEvent, pos) => { $(dataEvent.node).trigger(dataEvent.eventName, dataEvent.data) })
  };

  proto.validateSchemaField = function(e, htmlField) {
    return this.validate(e, htmlField).then($.proxy(this.triggerEvents, this));
  };

  proto.validateSchemaFields = function(e, obj) {
    return $.when.apply(this, obj.data.map($.proxy((htmlField) => { return this.validate(e, htmlField)}, this))).then($.proxy(this.triggerEvents, this));
  };

  proto.attachHandlers = function() {
    $(this._node).on('psd.schema.validation', $.proxy(this.validateSchemaField, this));
    $(this._node).on('psd.schema.validations', $.proxy(this.validateSchemaFields, this));
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'DataTableSchemaValidation': DataTableSchemaValidation});
  });

}(jQuery))
