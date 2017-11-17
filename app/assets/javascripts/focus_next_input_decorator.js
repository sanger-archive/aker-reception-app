(function($,undefined) {
  function FocusNextInputDecorator(node, params) {
    this.node = $(node);
    this.params = params;

    this.attachHandlers();
  }

  var proto = FocusNextInputDecorator.prototype;

  proto.attachHandlers = function() {
    $('input', this.node).each($.proxy(function(pos, input) {
      $(input).on('keyup', $.proxy(this.onKeyUp, this, $(input)));
    }, this));
  };

  proto.onKeyUp = function(input, e) {
    if (e.keyCode == 13)  {
      input.next().focus();
    }
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'FocusNextInputDecorator': FocusNextInputDecorator});
  });

}(jQuery));