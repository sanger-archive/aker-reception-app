import TableCellMessageStore from 'table_cell_message_store'

class TooltipsManager {
  constructor(inputs) {
    this.inputs = inputs
    this.inputsData = this.inputs.map($.proxy((pos, input) => { return this.inputDataFor(input)}, this))
    this.store = new TableCellMessageStore()

    this.tooltipsConfig = []    
  }

  updateValidations() {
    setTimeout($.proxy(() => {
      this.inputsData.each($.proxy((pos, inputData) => { 
        this.setMessageToInput(inputData)
      }, this))
    }, this), 500)
  }

  loadMessages(data) {
    this.store.loadMessages(data)
  }

  /**
   * Returns the fields from the cell of the given ID
   */
  inputDataFor(input) {
    const id = $(input).attr('id')
    const matching = id.match(/labware\[([0-9]*)\]address\[([A-Z0-9:]*)\]fieldName\[(\w*)\]/);
    if (matching) {
      return {
        "input": input,
        "labwareIndex": matching[1],
        "address": matching[2],
        "fieldName": matching[3]
      };
    }
    return null;
  }

  setMessageToInput(inputData) {
    var msg = this.store.messageFor(inputData)
    if (msg) {
      var cssClass = msg.errors ? 'has-error' : 'has-warning'
      var text = Object.values(msg.errors ? msg.errors : msg.warnings)[0]
      var input = inputData.input

      this.cleanTooltip(input)
      this.buildTooltip(input, text)

      $(input).data('fromUserInteraction', false)
      $(input).parent().addClass(cssClass)
    }
  }  

  buildTooltip(input, msg) {
    var container = $(input).parent();
    var tooltip = container.tooltip({
      title: msg,
      trigger: 'manual',
      placement: 'bottom',
      container: container
    });
    container.data('bs.tooltip').options.title = msg;
    var onClickInput = $.proxy(function() {
      this.tooltip('show'); 
    }, container);
    var onBlurInput = $.proxy(function() { 
      this.tooltip('hide'); 
    }, container);

    $(input).on('click.tooltip', onClickInput);
    $(input).on('blur.tooltip', onBlurInput);

    this.tooltipsConfig.push({ container, input });
  }

  findTooltipIndexForInput(input) {
    // This is intented to be equivalent to:
    // this.tooltipsConfig.findIndex((config) => { return (config.input === input) })
    var index = -1;
    this.tooltipsConfig.some($.proxy(function(config, pos) { 
      if (config.input === input) {
        index = pos;
        return true;
      }
    }, this));
    return index;
  }

  cleanTooltip(input) {
    var index = this.findTooltipIndexForInput(input);
    if (index >= 0) {
      const config = this.tooltipsConfig.splice(index, 1)[0];

      $(config.input).off('click.tooltip');
      $(config.input).off('blur.tooltip');
    }
  }

  cleanTooltips() {
    for (var i=0; i<this.tooltipsConfig.length; i++) {
      this.cleanTooltip(this.tooltipsConfig[i]);
    }
    this.tooltipsConfig=[];
  }


}

export default TooltipsManager