(function($,undefined) {

  function SyncSelectValue(node, params) {
    this.node = node;
    this.params = params;

    this.attachHandlers();
  }

  var proto = SyncSelectValue.prototype;

  proto.attachHandlers = function() {
    // Mirrors dropdown selection between both dropdown menus on the Completed
    // Submissions page
    $(this.params.cssSyncSelect).change($.proxy(this.onChange, this));
  };

  proto.onChange = function(event) {
    var value = $(event.target).val();
    var id = event.target.id;
    $(this.params.cssSyncSelect).each(function(pos, node) {
      if (node.id!==id) {
        $(node).val(value);
      }
    })
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'SyncSelectValue': SyncSelectValue});
  });  

})(jQuery);

