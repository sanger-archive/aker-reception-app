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

    this.form = $('form')
    $(this.form).data('remote', true)
    this.currentTab = this.tabs()[0]

    this.attachHandlers()
  }

  update() {
    this.tabComponents.each((pos, tab) => { tab.update()})
  }

  attachHandlers() {
    this.tabs().on('hide.bs.tab', $.proxy(this.saveTab, this))
    this.tabs().on('show.bs.tab', $.proxy(this.restoreTab, this))
    this.inputs().on('blur', $.proxy(this.validateInput, this, true))
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
  * Triggers a schema validation request to the DataTableSchemaValidation manager
  **/
  validateInput(fromUserInteraction, e) {
    let input = e.target
    let name = $(input).parents('td').data('psd-schema-validation-name')
    //$(input).parent().removeClass('has-error')

    // It will store in the input that we are interacting with the input, so we can take
    // decissions in future about how to display the potential errors
    let tabForInput = this.findTabForInput(input)[0]
    let inputData = tabForInput.inputDataFor(input)
    this.messageStore.clearInput(inputData)

    $(input).data('fromUserInteraction', fromUserInteraction)
    if (name) {
      $(input).trigger('psd.schema.validation', {
        node: input,
        name: name,
        value: $(input).val()
      })
    }
  }

  /**
  * Loads the data of all the materials for the tab from the receptions app
  **/
  restoreTab(e) {
    this.currentTab = this.findTabForNode(e.target)[0]
    this.currentTab.restore()
  }

  /**
  * Saves the data for the tab into the receptions app
  **/
  saveTab(e, leaving) {
    this.currentTab = this.findTabForNode(e.target)[0]
    this.currentTab.save()

    let changeTabField = null

    // If we are not leaving, we set up an input to tell the server we don't want to go to the next step
    if (!leaving) {
      changeTabField = $("<input name='material_submission[change_tab]' value='true' type='hidden' />")
      $(this.form).append(changeTabField)
    }
    let promise = $.post($(this.form).attr('action'), $(this.form).serialize()).then(
      $.proxy(this.onReceive, this),
      $.proxy(this.onError, this)
    )
    // We remove the previous setting
    if (!leaving) {
     changeTabField.remove()
    }
    return promise
  }

  /**
  * Saves the received data into the table store, so it will update the table
  **/
  onReceive(data) {
    this.messageStore.loadMessages(data)
    this.update()
  }

  onError(e) {
    this.showAlert({
      title: 'Validation Error',
      body: 'We could not save the current content due to an error'
    })
  }

  onValidation(e,data) {
    return this.onReceive(data)
  }

  showAlert(data) {
    $('#page-error-alert > .alert-title').html(data.title)
    $('#page-error-alert > .alert-msg').html(data.body)
    $('#page-error-alert').toggleClass('hidden', false)
  }

  setMessageForLabware(labwareId, message, facility) {
    if (facility == 'error') {
      this.addErrorToMainAlertError('<li>Labware '+message.labwareIndex+', errors: '+Object.values(message.errors)[0]+"</li>");
      var tab = document.getElementById("labware_tab["+message.labwareIndex+"]");
      this.setErrorToTab(tab);      
    }
  }  

  resetMainAlertError() {
    $('#page-error-alert > .alert-msg').html('')
    $('#page-error-alert').toggleClass('hidden', true)
  }

  addErrorToMainAlertError(text) {
    $('#page-error-alert > .alert-msg').append(text)
  }

  /**
  * Before going to the next page, it waits for the result of the saveTab operation. If the
  * saving was correct it let us go to the next step. Otherwise it will display the error
  * message and remain in this tab.
  **/
  saveCurrentTabBeforeLeaving(button, e) {
    e.stopPropagation()
    e.preventDefault()

    this.currentTab = this.findTabForNode(e.target)[0]

    //this.saveTab({target: this.currentTab})
    let promise = this.currentTab.save()
    if (promise === null) {
      return
    }
    promise.then($.proxy(function(data) {
      if (data.update_successful && (this.tableStore.isEmpty())) {
        window.location.href = $(button).attr('href')
      } else {
        this.showAlert({
          title: 'Validation problems',
          body: 'Please review and solve the validation problems before continuing'})
        if (!data.update_successful) {
          this.messageStore.loadMessages(data)
        }
        this.currentTab.update()
      }
    }, this), $.proxy(this.onError, this))
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