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
        this._loadedSchema = {type: 'Mytype', type: 'object', properties: json };
        return this._loadedSchema;
    }, this)});
  };

  proto.validationError = function(node, attr, msg) {
    var data = {
      errors: {},
      labware_id: $('input#material_submission_labwares_attributes_0_id', $(node).parents('div.tab-content')).first().val(),
      well_id: $('input', $(node).parents('tr')).first().val()
    };
    if (!!attr) {
      data.errors[attr] = msg;
    }

    $(node).trigger('psd.schema.error', {
      node: node,      
      messages: [ data ]
    });
  };

  proto.validateSchemaField = function(e, msg) {
    var schema = this._loadedSchema.properties[msg.name];
    var valid = true;
    if (!!schema) {
      if (!!schema.required) {
        if (!msg.value) {
          this.validationError(msg.node, msg.name, 'Client side validation: The field '+msg.name+' is required');
          valid=false;
        }
      }
      if ((!!schema.allowed)) {
        if ($.inArray(msg.value, schema.allowed)==-1) {
          this.validationError(msg.node, msg.name, 'Client side validation: The field should have any of these values ['+schema.allowed.join(',')+']');
          valid=false;
        }
      }
    }
    if (valid) {
      var node = msg.node;
      var data = {
        errors: {},
        labware_id: $('input#material_submission_labwares_attributes_0_id', $(node).parents('div.tab-content')).first().val(),
        well_id: $('input', $(node).parents('tr')).first().val(),
        update_successful: true
      };
      $(node).trigger('psd.schema.error', {
        node: node,      
        messages: [ data ]
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