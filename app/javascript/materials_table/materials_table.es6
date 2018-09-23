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
    this.tableStore.currentTab().update()
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

    //debugger;
    //$($('table', this.node)[1]).on('psd.update-table', $.proxy(this.onUploadedFile, this));
    $('table', this.node).on('psd.update-table', $.proxy(this.onUploadedFile, this));

    $('input[type=submit]').on('click', $.proxy(this.toNextStep, this))
  }

  onUploadedFile() {
    this.tableStore.currentTab().validate()
  }

  /**
  * Loads the data of all the materials for the tab from the receptions app
  **/
  restoreTab(e) {
    let tab = this.findTabForNode(e.target)[0]
    let promise = tab.restore().then($.proxy(this.tableStore.setCurrentTab, this.tableStore, tab))
    if (this.tableStore.hasVisitedBefore(tab)) {
      promise = promise.then($.proxy(this.update, this))
    }
    return promise
  }

  /**
  * Saves the data for the tab into the receptions app
  **/
  saveTab(e) {
    let tab = this.findTabForNode(e.target)[0]
    //return tab.save().then($.proxy(tab.update, tab))
    //this.tableStore.setCurrentTab(this.findTabForNode(e.target)[0])

    return tab.save().then($.proxy(tab.update, tab))
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
      if (data.update_successful) {
        window.location.href = $(button).attr('href')
      }
      return data
    }, this)).then($.proxy(this.updateAllTabs, this))
    return promise
  }

  updateAllTabs() {
    this.tabComponents.each((tab) => {tab.update()})
  }

  onValidation(e, ...others) {
    let data
    if (others.length>=0) {
      data = others
    } else {
      data = [others]
    }
    data.forEach($.proxy((datum, pos) => {
      this.messageStore.addMessages(datum)
    }, this))
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
  * Finds the tab component that has control over a DOM node
  **/
  findTabForNode(node) {
    return this.tabComponents.filter($.proxy(function(pos, tab) { 
      return (tab.node() === node)
    }, this))
  }

}

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'SingleTableManager': MaterialsTable});
  });

export default MaterialsTable