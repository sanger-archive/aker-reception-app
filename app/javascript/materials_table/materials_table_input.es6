class MaterialsTableInput {
  constructor(inputData, tab, tableStore, messageStore) {
    this.tab = tab
    this.inputData = inputData
    this.tableStore = tableStore
    this.messageStore = messageStore

    this.validate()
    this.attachHandlers()
  }

  attachHandlers() {
    $(this.inputData.input).on('blur', $.proxy(this.validate, this))    
  }

  update() {
    this.cleanMessage()
    var msg = this.messageStore.messageFor(this.inputData)
    if (msg) {
      setTimeout($.proxy(() => { this.showMessage(msg)}, this), 0)
    }
  }

  restore() {
    var value = this.tableStore.getValueForInput(this.inputData)
    if (value) {
      $(this.inputData.input).val(value)
      this.update()
    }
  }

  save() {
    this.tableStore.setValueForInput(this.inputData)
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
    this._hasTooltip = true
  }


  cleanMessage() {
    if (this._hasTooltip) {
      $(this.inputData.input).parent().removeClass('has-error')
      $(this.inputData.input).parent().removeClass('has-warning')
      $(this.inputData.input).off('click.tooltip')
      $(this.inputData.input).off('blur.tooltip')
    }
    this._hasTooltip = false
  }

  /**
  * Triggers a schema validation request to the DataTableSchemaValidation manager
  **/
  validate() {
    this.messageStore.clearInput(this.inputData)
    let input = this.inputData.input
    let name = $(input).parents('td').data('psd-schema-validation-name')
    if (name) {
      $(input).trigger('psd.schema.validation', {
        node: input,
        name: name,
        value: $(input).val()
      })
    }
  }



}

export default MaterialsTableInput