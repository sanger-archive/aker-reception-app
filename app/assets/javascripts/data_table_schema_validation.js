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

  proto.validationError = function(node, attr, msg) {
    var data = this.dataForNode(node);
    if (attr) {
      data.errors[attr] = msg;
    }
    $(node).trigger('psd.schema.error', {
      node: node,
      messages: [ data ]
    });
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

  proto.schemaChecks = {
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

  proto.failSchemaCheck = function(schema, msg, failFunct, textFunct) {
    if (failFunct(schema, msg)) {
      this.validationError(msg.node, msg.name, textFunct(schema, msg));
      return true;
    }
    return false;
  };

  /**
   * Fails if the HMDMC number is invalid
   * Returns true if it fails.
   */
  proto.hmdmcCheck = function(fieldProperties, hmdmcField) {
    // Only validate the HMDMC number if there is one
    if (hmdmcField.value) {
      var hmdmcPattern = new RegExp('^[0-9]{2}\/[0-9]{3}$');

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
            url: "/hmdmc",
            method: "GET",
            data: { hmdmc: hmdmcField.value.replace("/", "_") },
            success: $.proxy(function(validHMDMC) {
              this.verifiedHMDMC[hmdmcField.value] = validHMDMC;
              $(hmdmcField.node).trigger('psd.schema.validation', {
                node: hmdmcField.node,
                name: hmdmcField.name,
                value: hmdmcField.value
              });
            }, this)
          });
        }
      } else {
        var hmdmcFormatError = "The HMDMC number should be in the format ##/###."
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
  proto.validateSchemaField = function(e, htmlField) {
    // Get the properties of the field from the schema
    if (this._loadedSchema.properties['hmdmc']) {
      this._loadedSchema.properties['hmdmc']['required'] = false;
    }
    var fieldProperties = this._loadedSchema.properties[htmlField.name];

    var failed = false;
    if (fieldProperties) {
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
    if (!failed) {
      var node = htmlField.node;

      $(node).trigger('psd.schema.error', {
        node: node,
        update_successful: false,
        messages: [ $.extend(this.dataForNode(node), { update_successful: false }) ]
      });
    }
  };

  proto.attachHandlers = function() {
    $(this._node).on('psd.schema.validation', $.proxy(this.validateSchemaField, this));
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'DataTableSchemaValidation': DataTableSchemaValidation});
  });

}(jQuery))
