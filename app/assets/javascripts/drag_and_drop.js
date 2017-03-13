(function($, undefined) {

  function DragAndDrop(node, params) {
    this.node = $(node);
    this.params = params;

    $(this.node).on('dragAndDrop.attachHandlers', $.proxy(this.attachHandlers, this));
  }

  var proto = DragAndDrop.prototype;

  proto.attachHandlers = function() {
    this.droppableElements = $(this.params.cssDropable, $(this.node));

    $(this.droppableElements).each($.proxy(function(pos, tr) {
      $(tr).on('drop', $.proxy(this.onDrop, this, tr));
      $(tr).on('dragover', $.proxy(this.onDragOver, this, tr));
      $(tr).on('dragleave', $.proxy(this.onDragOut, this, tr));
    }, this));
  };

  proto.onDragOver = function(tr, event) {
    event.preventDefault();
    $(tr).addClass('success')
  };

  proto.onDragOut = function(tr, event) {
    $(tr).removeClass('success')
  };


  proto.onDrop = function(tr, event) {
    event.preventDefault();
    var submissionIds = JSON.parse(event.originalEvent.dataTransfer.getData("text"));
    var collectionId  = $(tr).data('uniqueid');
    Aker.claim(submissionIds, collectionId);
    $(tr).removeClass('success')
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'DragAndDrop': DragAndDrop});
  });

}(jQuery))