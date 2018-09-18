class MessageStore {
  constructor() {
    this.messageStore = {}
  }

  loadMessages(data) {
    if (data && data.messages) {
      data.messages.forEach($.proxy((message) => {
        if (!this.messageStore[message.labwareIndex]) {
          this.messageStore[message.labwareIndex]={}
        }
        this.storeCellMessage(message.labwareIndex, message.address, message)
      }, this))
    }
    return true
  }

  messageFor(inputData) {
    if (this.messageStore[inputData.labwareIndex] && this.messageStore[inputData.labwareIndex][inputData.address]
      && this.messageStore[inputData.labwareIndex][inputData.address][inputData.fieldName]) {
      return this.messageStore[inputData.labwareIndex][inputData.address][inputData.fieldName]
    }
    return null
  }

  isEmpty() {
    return (Object.keys(this.messageStore).length == 0)
  }

  /**
  * Private methods
  **/
  anyErrorsForLabwareIndex(labwareIndex) {
    if (labwareIndex && this.messageStore) {
      let lwe = this.messageStore[labwareIndex]
      if (lwe) {
        for (let i of lwe) {
          if (lwe[i] && !$.isEmptyObject(lwe[i])) {
            return true
          }
        }
      }
    }
    return false
  }

  storeCellMessage(labwareIndex, address, message) {
    if (!this.messageStore[labwareIndex]) {
      this.messageStore[labwareIndex]={}
    }
    if (!this.messageStore[labwareIndex][address]) {
      this.messageStore[labwareIndex][address]={}
    }
    /** Json Schema error message from the JS client */
    this.storeCellMessageByFacility(labwareIndex, address, 'errors', message)
    this.storeCellMessageByFacility(labwareIndex, address, 'warnings', message)
  }

  storeCellMessageByFacility(labwareIndex, address, facility, message) {
    if (message[facility]) {
      for (let fieldName in message[facility]) {
        //let fieldName = key.replace(/.*\./, '')
        if (!this.messageStore[labwareIndex][address][fieldName]) {
          this.messageStore[labwareIndex][address][fieldName] = {}
        }
        if (!this.messageStore[labwareIndex][address][fieldName][facility]) {
          this.messageStore[labwareIndex][address][fieldName][facility] = []
        }
        this.messageStore[labwareIndex][address][fieldName][facility].push(message[facility][fieldName])
      }
    }
  }

}

export default MessageStore