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

  proto.schemaChecks = {
    failsDataValueRequired: function(schema, msg) {
      return (schema.required && !msg.value);
    },
    failsDataValueAllowed: function(schema, msg) {
      return (schema.enum && msg.value && $.inArray(msg.value, schema.enum)==-1);
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