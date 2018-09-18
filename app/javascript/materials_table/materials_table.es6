import MaterialsTableTab from 'materials_table/materials_table_tab'
import MaterialsTableStore from 'materials_table/stores/materials_table_store'
import MessageStore from 'materials_table/stores/message_store'

class MaterialsTable {
  constructor(node, params) {
    this.node = $(node)
    this.params = params

    this.tableStore = new MaterialsTableStore(this.params)
    this.messageStore = new MessageStore()


    this.tabComponents = this.tabs().map($.proxy((pos, tab) => {
      return new MaterialsTableTab(tab, this.tableStore, this.messageStore)
    }, this))

    this.tableStore.setCurrentTab(this.tabComponents[0])

    this.attachHandlers()
  }

  update() {
    this.tabComponents.each((pos, tab) => { tab.update() })
  }

  attachHandlers() {
    this.tabs().on('hide.bs.tab', $.proxy(this.saveTab, this))
    this.tabs().on('show.bs.tab', $.proxy(this.restoreTab, this))

    $('form').on('submit.rails', $.proxy(this.saveTab, this))

    // If you have one
    let button = $('.save')
    button.on('click', $.proxy(this.saveCurrentTabBeforeLeaving, this, button))
    $(this.node).on('psd.schema.success', $.proxy(this.onValidation, this))
    $(this.node).on('psd.schema.error', $.proxy(this.onValidation, this))
    $(this.node).on('psd.schema.warning', $.proxy(this.onValidation, this))

    $('input[type=submit]').on('click', $.proxy(this.toNextStep, this))
  }


  /**
  * Loads the data of all the materials for the tab from the receptions app
  **/
  restoreTab(e) {
    this.tableStore.setCurrentTab(this.findTabForNode(e.target)[0])
    return this.tableStore.currentTab().restore().then($.proxy(this.update, this))
  }

  /**
  * Saves the data for the tab into the receptions app
  **/
  saveTab(e) {
    this.tableStore.setCurrentTab(this.findTabForNode(e.target)[0])
    return this.tableStore.currentTab().save().then($.proxy(this.update, this))
  }

  /**
  * Before going to the next page, it waits for the result of the saveTab operation. If the
  * saving was correct it let us go to the next step. Otherwise it will display the error
  * message and remain in this tab.
  **/
  saveCurrentTabBeforeLeaving(button, e) {
    e.stopPropagation()
    e.preventDefault()
    let promise = this.tableStore.currentTab().saveWithoutLeaving().then($.proxy((data) => {
      if (this.messageStore.isEmpty()) {
        window.location.href = $(button).attr('href')
      }
      return data
    }, this)).then($.proxy(this.update, this))
    return promise
  }

  onValidation(e,data) {
    this.messageStore.loadMessages(data)
    return this.update()
  }

  /**
  * Performs a redirect to the next page
  **/
  toNextStep(e) {
    this.nextStepUrl = window.location.href.replace('provenance', 'ethics')
    window.location.href = this.nextStepUrl
  }

  /**
  * DOM nodes for the tabs
  **/
  tabs() {
    return (this._tabs) ? this._tabs : (this._tabs = $('a[data-toggle="tab"]'))
  }

  /**
  * DOM input nodes for the table. Only nodes related with the material information are returned
  **/
  inputs() {
    if (!this._inputs) {
      this._inputs = $('form input').filter(function(pos, input) {
        return($(input).attr('id') && $(input).attr('id').search(/labware/)>=0)
      })
    }
    return this._inputs
  }

  /**
  * Finds the tab component that has control over a DOM node
  **/
  findTabForNode(node) {
    return this.tabComponents.filter($.proxy(function(pos, tab) { 
      return (tab.node() === node)
    }, this))
  }

  findTabForInput(input) {
    return this.tabComponents.filter($.proxy(function(pos, tab) { 
      return (tab.inputs().toArray().includes(input))
    }, this))
  }

}

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'SingleTableManager': MaterialsTable});
  });

export default MaterialsTable