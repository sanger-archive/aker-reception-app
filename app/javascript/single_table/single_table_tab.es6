import SingleTableInput from 'single_table_input'

class SingleTableTab {

  constructor(tab, tableStore, messageStore) {
    this.tab = tab
    this.tableStore = tableStore
    this.messageStore = messageStore

    this.inputTooltips = inputs().map($.proxy((pos, input) => { 
      new SingleTableInput(input, tab, this.tableStore, this.messageStore)
    }, this))

    this._cssNotEmptyTabClass = 'bg-info'
    this._cssEmptyTabClass = 'bg-warning'
    this._cssErrorTabClass = 'bg-danger'
  }

  update() {
    if (this.messageStore.anyErrorsForLabwareIndex(this.tabLabwareIndex())) {
      $(tab).addClass(this._cssErrorTabClass);
      $(tab).removeClass(this._cssNotEmptyTabClass);      
    } else {
      $(tab).removeClass(this._cssErrorTabClass);
    }
    this.inputTooltips.each((pos, tooltip) => { tooltip.update() })
  }

  save() {
    this.inputTooltips.each($.proxy(this.save, this, data));
  }


  restore() {
    this.inputTooltips.each($.proxy(this.restore, this, data));
  }

  tabLabwareIndex() {
    var id = this.tab.attr('id');
    var matching = id.match(/labware_tab\[([0-9]+)\]/);
    return matching ? matching[1] : null;
  }


  updateTabContentPresenceStatus() {
    $(this.tab).toggleClass(this._cssNotEmptyTabClass, this.isTabWithContent());
    $(this.tab).toggleClass(this._cssEmptyTabClass, !this.isTabWithContent());
  }

  isTabWithContent() {
    var data = this.tableStore.dataForTab(this.tab); // data is the labware for this tab

    return (data["contents"] != null);
  }

}

export default SingleTableTab