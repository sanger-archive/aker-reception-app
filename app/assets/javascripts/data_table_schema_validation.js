(function($, undefined) {
	function DataTableSchemaValidation(node, params) {
    this._node = $(node);
    this.params = params;
    this._loadedSchema = null;
    this.loadSchema().then($.proxy(this.attachHandlers, this));
	}

	var proto = DataTableSchemaValidation.prototype;

  proto.loadSchema = function() {
    return $.ajax({url: '/materials_schema',
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
    }
  };

  proto.failSchemaCheck = function(schema, msg, failFunct, textFunct) {
    if (failFunct(schema, msg)) {
      this.validationError(msg.node, msg.name, textFunct(schema, msg));
      return true;
    }
    return false;
  };

  proto.validateSchemaField = function(e, msg) {
    var schema = this._loadedSchema.properties[msg.name];

    var successful = true;
    if (schema) {
      successful = !(
            this.failSchemaCheck(schema, msg, this.schemaChecks.failsDataValueRequired, function(schema, msg) {
              return 'The field '+msg.name+' is required'
            }) ||
            this.failSchemaCheck(schema, msg, this.schemaChecks.failsDataValueAllowed, function(schema, msg) {
              return 'The field should have any of these values ['+schema.enum.join(',')+']';
            }));
    }

    var node = msg.node;
    // We have to specify update_successful true here or validation doesn't work. Shrug.
    $(node).trigger('psd.schema.error', {
      node: node,
      update_successful: true,
      messages: [ $.extend(this.dataForNode(node), { update_successful: true}) ]
    });
  };

  proto.attachHandlers = function() {
    $(this._node).on('psd.schema.validation', $.proxy(this.validateSchemaField, this));
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'DataTableSchemaValidation': DataTableSchemaValidation});
  });



}(jQuery))