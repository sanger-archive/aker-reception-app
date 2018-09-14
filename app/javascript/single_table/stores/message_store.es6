class MessageStore {
  constructor() {
    this.messageStore = {}
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
            this.messageStoreCellNameMessage(message.labwareIndex, address, message);
          } else {
            this.messageStoreTableMessage(message.labwareIndex, message)
          }
        }
      }
    }
  }

  messageFor(inputData) {
    return (this.messageStore[inputData.labwareIndex] && this.messageStore[inputData.labwareIndex][inputData.address]
        && this.messageStore[inputData.labwareIndex][inputData.address][inputData.fieldName])
  }


  /**
  * Private methods
  **/
  anyErrorsForLabwareIndex(labwareIndex) {
    if (labwareIndex && this.messageStore) {
      var lwe = this.messageStore[labwareIndex];
      if (lwe) {
        for (var i in lwe) {
          if (lwe[i] && !$.isEmptyObject(lwe[i])) {
            return true;
          }
        }
      }
    }
    return false;
  }

  resetLabwareMessages(labwareIndex) {
    this.messageStore[labwareIndex]={};
  }

  storeTableMessage(labwareIndex, message) {
    return storeCellNameMessage(labwareIndex, '__main__', message)
  }

  storeCellNameMessage(labwareIndex, address, message) {
    if (!this.messageStore[labwareIndex]) {
      this.resetCellNameErrors(labwareIndex);
    }
    if (!this.messageStore[labwareIndex][address]) {
      this.messageStore[labwareIndex][address]={};
    }
    if (message.schema) {
      /** Json schema error message from the server json-schema gem */
      for (var i=0; i<message.schema[0].length; i++) {
        var obj = message.schema[0][i].message;
        var fieldName = obj.fragment.replace(/#\//, '')
        var text = obj.message;
        this.messageStore[labwareIndex][address][fieldName] = text;
      }
    } else {
      /** Json Schema error message from the JS client */
      this.messageStoreCellMessageByFacility(labwareIndex, address, 'errors', message)
      this.messageStoreCellMessageByFacility(labwareIndex, address, 'warnings', message)
    }
  }

  storeCellMessageByFacility(labwareIndex, address, facility, message) {
    for (var key in message[facility]) {
      var fieldName = key.replace(/.*\./, '');
      if (!this.messageStore[labwareIndex][address][fieldName]) {
        this.messageStore[labwareIndex][address][fieldName] = {}
      }
      if (!this.messageStore[labwareIndex][address][fieldName][facility]) {
        this.messageStore[labwareIndex][address][fieldName][facility] = []
      }
      this.messageStore[labwareIndex][address][fieldName][facility].push(message[facility][key])
    }
  }

}

export default MessageStore