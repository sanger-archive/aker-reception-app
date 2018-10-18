class MaterialsTableStore {
  constructor(store) {
    this.store = store
    this._alreadyVisited = []
  }

  setCurrentTab(tab) {
    if (!this._alreadyVisited.includes(tab)) {
      this._alreadyVisited.push(tab)
    }
    this._currentTab = tab
  }

  currentTab() {
    return this._currentTab
  }  

  hasVisitedBefore(tab) {
    return this._alreadyVisited.includes(tab)
  }

  dataForTab(tab) {
    // This returns the labware object linked to the tab
    for (var key in this.store) {
      if ($(tab).attr('href') === ('#Labware' + this.store[key].labware_index)) {
        return this.store[key]
      }
    }
    return null
  }

  getValueForInput(inputData) {
    var data = this.dataForTab(inputData.tab)
    var address = inputData.address
    var fieldName = inputData.fieldName
    if (data && data["contents"] && address && data["contents"][address] && fieldName) {
      return data["contents"][address][fieldName]
    }
    return null
  }

  setValueForInput(inputData) {
    var data = this.dataForTab(inputData.tab)
    if (data == null) {
      return
    }

    var info = inputData
    var input = inputData.input

    if (info && data.labware_index == info.labwareIndex) {

      // Get and santize the value of the input
      var v = $(input).val()
      if (v != null) {
        v = $.trim(v)
        if (v == '') {
          v = null
        }
      }
      if (v) {
        if (!data["contents"]) {
          data["contents"] = {}
        }
        if (!data["contents"][info.address]) {
          data["contents"][info.address] = {}
        }
        data["contents"][info.address][info.fieldName] = v
      } else if (this.getValueForInput(info) != null) {
        data["contents"][info.address][info.fieldName] = null
      }
    }    
  }
}

export default MaterialsTableStore