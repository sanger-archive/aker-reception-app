import MaterialsTableInput from 'materials_table/materials_table_input'

class MaterialsTableTab {

  constructor(tab, tableStore, messageStore) {
    this.tab = tab
    this.tableStore = tableStore
    this.messageStore = messageStore

    this.inputTooltips = this.inputs().map($.proxy((pos, input) => { 
      return new MaterialsTableInput(this.inputDataFor(input), tab, this.tableStore, this.messageStore)
    }, this))

    this.form = $('form')
    $(this.form).data('remote', true)

    this._cssNotEmptyTabClass = 'bg-info'
    this._cssEmptyTabClass = 'bg-warning'
    this._cssErrorTabClass = 'bg-danger'
    this._cssWarningTabClass = 'bg-warning'

    this.updateTabContentPresenceStatus()
  }

  update() {
    let isCurrentTab = (this.tableStore.currentTab() === this) 
    let hasWarning = (this.messageStore.anyWarningsForLabwareIndex(this.tabLabwareIndex()))
    let hasError = (this.messageStore.anyErrorsForLabwareIndex(this.tabLabwareIndex()))

    if (isCurrentTab && hasWarning) { this.showWarning() } else { this.hideWarning() }
    if (isCurrentTab && hasError) { this.showError() } else { this.hideError() }

    if (hasWarning) { $(this.tab).addClass(this._cssWarningTabClass) } else { $(this.tab).removeClass(this._cssWarningTabClass) }
    if (hasError) { $(this.tab).addClass(this._cssErrorTabClass) } else { $(this.tab).removeClass(this._cssErrorTabClass) }

    this.inputsForValidation().forEach((tooltip) => { tooltip.update() })
  }

  save() {
    this.inputTooltips.each((pos, tooltip) => { tooltip.save() })

    let promise = $.post($(this.form).attr('action'), $(this.form).serialize()).then(
      $.proxy(this.onReceive, this),
      $.proxy(this.onError, this)
    )
    return promise
  }

  saveWithoutLeaving() {
    // If we are not leaving, we set up an input to tell the server we don't want to go to the next step
    let changeTabField = $("<input name='manifest[change_tab]' value='true' type='hidden' />")
    $(this.form).append(changeTabField)

    let promise = this.save()

    // We remove the previous setting
    changeTabField.remove()  

    return promise
  }

  restore() {
    this.inputTooltips.each((pos, tooltip) => { 
      tooltip.restore() 
    })

    //this.validate()

    let defer = new $.Deferred()
    return defer.resolve(true)
  }

  node() {
    return this.tab
  }

  tabLabwareIndex() {
    var id = $(this.tab).attr('id');
    var matching = id.match(/labware_tab\[([0-9]+)\]/);
    return matching ? matching[1] : null;
  }


  updateTabContentPresenceStatus() {
    $(this.tab).toggleClass(this._cssNotEmptyTabClass, this.isTabWithContent());
    $(this.tab).toggleClass(this._cssEmptyTabClass, !this.isTabWithContent());
  }

  isTabWithContent() {
    var data = this.tableStore.dataForTab(this.tab); // data is the labware for this tab

    return (data && (data["contents"] != null));
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

  /**
  * Saves the received data into the table store, so it will update the table
  **/
  onReceive(data) {
    this.messageStore.loadMessages(data)
    this.update()
    return data
  }

  onError(e) {
    this.showAlert({
      title: 'Validation Error',
      body: 'We could not save the current content due to an error'
    })
  }

  showAlert(data, node) {
    $('.alert-title', node).html(data.title)
    $('.alert-msg', node).html(data.body)
    $(node).toggleClass('hidden', false)
  }

  hideError() {
    $('#page-error-alert').toggleClass('hidden', true)
  }

  hideWarning() {
    $('#page-warning-alert').toggleClass('hidden', true)
  }

  showError() {
    this.showAlert({
      title: 'Validation errors',
      body: 'Please review and solve the validation errors before continuing'}, $('#page-error-alert'))
  }

  showWarning() {
    this.showAlert({
      title: 'Validation warnings',
      body: 'Please check the validation warnings in case it was not what you expected '}, $('#page-warning-alert'))
  }


  validate() {
    $('table').trigger('psd.schema.validations', {data: this.inputsForValidation().map((input,pos) => { 
      return input.dataForValidation() 
    })})
  }

  /**
  * DOM input nodes for the table. Only nodes related with the material information are returned
  **/
  inputs() {
    if (!this._inputs) {
      let idx = this.labwareIndex()
      this._inputs = $('form input,select').filter(function(pos, input) {
        return($(input).attr('id') && $(input).attr('id').search("labware\\["+idx+"\\]")>=0)
      })
    }
    return this._inputs
  }

  inputsByAddress() {
    return this.inputTooltips.toArray().reduce((memo, tooltip) => {
      if (!memo[tooltip.inputData.address]) {
        memo[tooltip.inputData.address] = []
      }
      memo[tooltip.inputData.address].push(tooltip)
      return memo
    }, {})
  }

  inputsForValidation() {
    let obj = this.inputsByAddress()
    let list = []
    for (let key in obj) {
      if (obj[key].some((tooltip) => { return ($(tooltip.inputData.input).val().length >0) })) {
        list=list.concat(obj[key])
      }
    }
    return list
  }

  labwareIndex() {
    return $(this.tab).attr('href').match(/#Labware([\d]*)/)[1]
  }

}


export default MaterialsTableTab