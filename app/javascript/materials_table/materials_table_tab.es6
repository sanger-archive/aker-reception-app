import MaterialsTableInput from 'materials_table/materials_table_input'

class MaterialsTableTab {

  constructor(tab, tableStore, messageStore) {
    this.tab = tab
    this.tableStore = tableStore
    this.messageStore = messageStore

    this.inputTooltips = this.inputs().map($.proxy((pos, input) => { 
      return new MaterialsTableInput(this.inputDataFor(input), tab, this.tableStore, this.messageStore)
    }, this))

    this._cssNotEmptyTabClass = 'bg-info'
    this._cssEmptyTabClass = 'bg-warning'
    this._cssErrorTabClass = 'bg-danger'

    this.updateTabContentPresenceStatus()
  }

  update() {
    if (this.messageStore.anyErrorsForLabwareIndex(this.tabLabwareIndex())) {
      $(this.tab).addClass(this._cssErrorTabClass);
      $(this.tab).removeClass(this._cssNotEmptyTabClass);      
    } else {
      $(this.tab).removeClass(this._cssErrorTabClass);
    }
    this.inputTooltips.each((pos, tooltip) => { tooltip.update() })
  }

  save() {
    this.inputTooltips.each((pos, tooltip) => { tooltip.save() })
  }

  restore() {
    this.inputTooltips.each((pos, tooltip) => { tooltip.restore() })
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
  * DOM input nodes for the table. Only nodes related with the material information are returned
  **/
  inputs() {
    if (!this._inputs) {
      let idx = this.labwareIndex()
      this._inputs = $('form input').filter(function(pos, input) {
        return($(input).attr('id') && $(input).attr('id').search("labware\\["+idx+"\\]")>=0)
      })
    }
    return this._inputs
  }

  labwareIndex() {
    return $(this.tab).attr('href').match(/#Labware([\d]*)/)[1]
  }

}


export default MaterialsTableTab