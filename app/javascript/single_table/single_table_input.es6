class SingleTableInput {
  constructor(input, tab, tableStore, messageStore) {
    this.tab = tab
    this.inputData = this.inputDataFor(input)
    this.tableStore = tableStore
    this.messageStore = messageStore
  }

  update() {
    var msg = this.messageStore.messageFor(this.inputData)
    if (msg) {
      this.cleanMessage()
      this.showMessage(msg)
    }
  }

  restore() {
    var value = this.tableStore.getDataForInput(this.inputData)
    if (value) {
      $(this.inputData.input).val(value)
      this.update()
    }
  }

  save() {
    this.tableStore.setDataForInput(this.inputData)
  }

  /**
   * Returns the fields from the cell of the given ID
   */
  inputDataFor(input) {
    var id = $(input).attr('id')
    return {
      id: id,
      input: input,
      tab: this.tab,
      labwareIndex: id.match(/^labware\[(\d*)\]/)[1],
      address: id.match(/address\[([\w:]*)\]/)[1],
      fieldName: id.match(/fieldName\[([\w_]*)\]/)[1]
    }
  }

  showMessage(msg) {
    var cssClass = msg.errors ? 'has-error' : 'has-warning'
    var text = Object.values(msg.errors ? msg.errors : msg.warnings)[0]

    var input = this.inputData.input
    var container = $(input).parent();
    var tooltip = container.tooltip({
      title: text,
      trigger: 'manual',
      placement: 'bottom',
      container: container
    });
    container.data('bs.tooltip').options.title = text;

    var onClickInput = $.proxy(function() {
      this.tooltip('show'); 
    }, container);
    var onBlurInput = $.proxy(function() { 
      this.tooltip('hide'); 
    }, container);

    $(input).on('click.tooltip', onClickInput);
    $(input).on('blur.tooltip', onBlurInput);
    $(input).data('fromUserInteraction', false)
    $(input).parent().addClass(cssClass)
  }


  cleanMessage() {
    $(this.inputData.input).off('click.tooltip')
    $(this.inputData.input).off('blur.tooltip')
  }


}

export default SingleTableInput