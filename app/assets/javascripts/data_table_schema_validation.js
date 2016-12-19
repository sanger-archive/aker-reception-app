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

  proto.validateSchemaField = function(e, msg) {
    debugger;
    var schema = this._loadedSchema[msg.name];
  };

  proto.attachHandlers = function() {
    $(this._node).on('psd.schema.validation', $.proxy(this.validateSchemaField, this));
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'DataTableSchemaValidation': DataTableSchemaValidation});
  });



}(jQuery))