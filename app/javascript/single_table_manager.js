import SingleTableMessageStore from 'single_table_message_store'
import TooltipMessageDisplay from 'tooltip_message_display'
import TabMessageDisplay from 'tab_message_display'

(function($, undefined) {

  function SingleTableManager(node, params) {
    this.node = $(node);
    this.params = params;

    this.tableStore = new SingleTableMessageStore(this.params)
    this.messageStore = new MessageStore()


    this.tabs = this.tabs().map($.proxy(pos, tab) => {
      tab = new TabMessageDisplay(tab, this.tableStore, this.messageStore)
      tab.updateTabContentPresenceStatus()
    })

    this.form = $('form');
    $(this.form).data('remote', true);
    this._tabs = $('a[data-toggle="tab"]');
    this.currentTab = this._tabs[0];

    this.attachHandlers();
  }

  var proto = SingleTableManager.prototype;

  proto.validateInput = function(input, fromUserInteraction) {
    var name = $(input).parents('td').data('psd-schema-validation-name');
    //$(input).parent().removeClass('has-error');

    // It will store in the input that we are interacting with the input, so we can take
    // decissions in future about how to display the potential errors
    $(input).data('fromUserInteraction', fromUserInteraction);
    if (name) {
      $(input).trigger('psd.schema.validation', {
        node: input,
        name: name,
        value: $(input).val()
      });
    }
  };

  proto.findTabForNode = function(node) {
    return this.tabs.filter($.proxy(function(tab) { 
      return (tab.node() === node)
    }, this));
  }

  proto.restoreTab = function(e) {
    this.currentTab = this.findTabForNode(e.target)[0];
    this.currentTab.restore();
  };

  proto.saveTab = function(e, leaving) {
    this.currentTab = this.findTabForNode(e.target)[0];
    this.currentTab.save();

    if (!leaving) {
      var changeTabField = $("<input name='material_submission[change_tab]' value='true' type='hidden' />");
      $(this.form).append(changeTabField);
    }
    var promise = $.post($(this.form).attr('action'), $(this.form).serialize()).then(
      $.proxy(this.onReceive, this, this.currentTab),
      $.proxy(this.onError, this)
    );

    if (!leaving) {
     changeTabField.remove();
    }
    return promise;
  };

  proto.onValidation = function(e,data) {
    return this.onReceive(data);
  }


  proto.onReceive = function(data) {
    this.tableStore.loadMessages(data)
  };

  proto.inputs = function() {
    return $('form input').filter(function(pos, input) {
      return($(input).attr('id') && $(input).attr('id').search(/labware/)>=0);
    });
  };

  proto.notEmptyInputs = function() {
    return $('form input').filter(function(pos, input) {
      return(($(input).val().length > 0) && $(input).attr('id') && $(input).attr('id').search(/labware/)>=0);
    });
  };



  proto.saveCurrentTab = function(e) {
    this.saveTab({target: this.currentTab}, false);
    if (e) {
      e.preventDefault();
    }
  };

  proto.showModal = function(data) {
    $('#alert-modal .modal-title').html(data.title);
    $('#alert-modal .modal-body').html(data.body);
    $('#alert-modal').modal();
  };

  proto.showAlert = function(data) {
    $('#page-error-alert > .alert-title').html(data.title);
    $('#page-error-alert > .alert-msg').html(data.body);
    $('#page-error-alert').toggleClass('hidden', false);
  };

  proto.resetMainAlertError = function() {
    $('#page-error-alert > .alert-msg').html('');
    $('#page-error-alert').toggleClass('hidden', true);
  };


  proto.addErrorToMainAlertError = function(text) {
    $('#page-error-alert > .alert-msg').append(text);
  };

  proto.isEmptyErrorCells = function() {
    return (Object.keys(this.errorCells).length == 0);
  };

  proto.saveCurrentTabBeforeLeaving = function(button, e) {
    e.stopPropagation();
    e.preventDefault();

    //this.saveTab({target: this.currentTab});
    var promise = this.currentTab.save();
    if (promise === null) {
      return;
    }
    promise.then($.proxy(function(data) {
      if (data.update_successful && (this.isEmptyErrorCells())) {
        window.location.href = $(button).attr('href');
      } else {
        this.showAlert({
          title: 'Validation problems',
          body: 'Please review and solve the validation problems before continuing'});
        this.setErrorToTab(this.currentTab);
        if (!data.update_successful) {
          this.tooltipsManager.loadMessages(data)
          //this.loadErrorsFromMsg(data, false);
        }
        this.tooltipsManager.updateValidations();
      }
    }, this), $.proxy(this.onError, this));
  };

  proto.onError = function(e) {
    this.showAlert({
      title: 'Validation Error',
      body: 'We could not save the current content due to an error'
    });
  };

  proto.toNextStep = function(e) {
    this.nextStepUrl = window.location.href.replace('provenance', 'ethics');
    window.location.href = this.nextStepUrl;
  };

  proto.attachHandlers = function() {
    $('a[data-toggle="tab"]').on('hide.bs.tab', $.proxy(this.saveTab, this));
    $('a[data-toggle="tab"]').on('show.bs.tab', $.proxy(this.restoreTab, this));
    $('table tbody tr td input').on('blur', $.proxy(function(e) {
      // This is a validation triggered by a user interaction, so we want to display a tooltip for it
      return this.validateInput(e.target, true);
    }, this));
    $('form').on('submit.rails', $.proxy(this.saveTab, this));

    // If you have one
    var button = $('.save');
    button.on('click', $.proxy(this.saveCurrentTabBeforeLeaving, this, button));
    $(this.node).on('psd.schema.success', $.proxy(this.onValidation, this));
    $(this.node).on('psd.schema.error', $.proxy(this.onValidation, this));
    $(this.node).on('psd.schema.warning', $.proxy(this.onValidation, this));

    $('input[type=submit]').on('click', $.proxy(this.toNextStep, this));
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'SingleTableManager': SingleTableManager});
  });

}(jQuery))
