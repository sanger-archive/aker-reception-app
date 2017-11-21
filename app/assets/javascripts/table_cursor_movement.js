(function($,undefined) {
  function TableCursorMovement(node, params) {
    this.node = $(node);
    this.params = params;

    this.rowLength = $('tbody tr:first input:visible', this.node).length;

    this.attachHandlers();
  }

  var proto = TableCursorMovement.prototype;

  proto.cursorBehaviour = function(e) {
    if (!this.textSelected(e.target)) {
      //return;
    }
    e = e || window.event;
    var pos = this.getPosition(e.target);
    if (e.keyCode == '38') { // up arrow
      this.moveTo(Math.max(0, pos-this.rowLength));
    }
    else if (e.keyCode == '40') { // down arrow
      this.moveTo(Math.min(this.allInputs().length, pos+this.rowLength));
    }
    else if (e.keyCode == '37') { // left arrow
      if ((pos % this.rowLength) !== 0) {
        this.moveTo(Math.max(0, pos-1));
      }
    }
    else if (e.keyCode == '39') { // right arrow
      if ((pos % this.rowLength) !== (this.rowLength-1)) {
        this.moveTo(Math.min(this.allInputs().length, pos+1));
      }
    }
    else if (e.keyCode == '13') { // Intro
      this.moveTo(Math.min(this.allInputs().length, pos+1));
    }    
  };

  proto.getPosition = function(input) {
    return this.allInputs().index(input);
  };

  proto.allInputs = function() {
    return $('tbody tr td input:visible', this.node);
  };

  proto.moveTo = function(pos) {
    this.moveToInput(this.allInputs()[pos]);
  };

  proto.moveToInput = function(input) {
    input.focus();
  };

  proto.selectText = function(e) {
    e.target.select();
  };

  proto.textSelected = function(text) {
    return (text.selectionEnd>0);
  };

  proto.attachHandlers = function() {
    $(this.allInputs()).on('keydown', $.proxy(this.cursorBehaviour, this));
    $(this.allInputs()).on('focus', $.proxy(this.selectText, this));
    $(this.allInputs()).on('click', $.proxy(this.toggleSelectMode, this, false));
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'TableCursorMovement': TableCursorMovement});
  });


}(jQuery));
