class TableCellMessageStore {
  constructor(params) {
    this.store = {}
  }

  messageFor(inputData) {
    return (this.store[inputData.labwareIndex] && this.store[inputData.labwareIndex][inputData.address]
        && this.store[inputData.labwareIndex][inputData.address][inputData.fieldName])
  }

  resetLabwareMessages(labwareIndex) {
    this.store[labwareIndex]={};
  }

  storeCellNameMessage(labwareIndex, address, message) {
    if (!this.store[labwareIndex]) {
      this.resetCellNameErrors(labwareIndex);
    }
    if (!this.store[labwareIndex][address]) {
      this.store[labwareIndex][address]={};
    }
    if (message.schema) {
      /** Json schema error message from the server json-schema gem */
      for (var i=0; i<message.schema[0].length; i++) {
        var obj = message.schema[0][i].message;
        var fieldName = obj.fragment.replace(/#\//, '')
        var text = obj.message;
        this.store[labwareIndex][address][fieldName] = text;
      }
    } else {
      /** Json Schema error message from the JS client */
      this.storeCellMessageByFacility(labwareIndex, address, 'errors', message)
      this.storeCellMessageByFacility(labwareIndex, address, 'warnings', message)
    }
  }

  storeCellMessageByFacility(labwareIndex, address, facility, message) {
    for (var key in message[facility]) {
      var fieldName = key.replace(/.*\./, '');
      if (!this.store[labwareIndex][address][fieldName]) {
        this.store[labwareIndex][address][fieldName] = {}
      }
      if (!this.store[labwareIndex][address][fieldName][facility]) {
        this.store[labwareIndex][address][fieldName][facility] = []
      }
      this.store[labwareIndex][address][fieldName][facility].push(message[facility][key])
    }
  }

  loadMessages(data) {
    if (data && data.messages) {
      for (var key in data) {
        for (var i = 0; i < data.messages.length; i++) {
          var message = data.messages[i];
          this.resetLabwareMessages(message.labwareIndex)
        }

        for (var i = 0; i<data.messages.length; i++) {
          var message = data.messages[i];
          var address = message.address;
          if (address) {
            this.storeCellNameMessage(message.labwareIndex, address, message);
          } else {
            this.addErrorToMainAlertError('<li>Labware '+message.labwareIndex+', errors: '+Object.values(message.errors)[0]+"</li>");
            var tab = document.getElementById("labware_tab["+message.labwareIndex+"]");
            this.setErrorToTab(tab);
          }
        }
      }
    }
  }
}

export default TableCellMessageStore