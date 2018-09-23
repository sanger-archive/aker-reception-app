class MessageStore {
  constructor() {
    this.messageStore = {}
  }

  loadMessages(data) {
    this.cleanErrors()
    return this.addMessages(data)
  }

  addMessages(data) {
    if (data && data.messages) {
      data.messages.forEach($.proxy((message) => {
        if (!this.messageStore[message.labwareIndex]) {
          this.messageStore[message.labwareIndex]={}
        }
        this.storeCellMessage(message.labwareIndex, message.address, message)
      }, this))
    }
    if (data.update_successful) {
      this.cleanErrors()
    }
    return true    
  }

  messageFor(inputData) {
    if (this.messageStore[inputData.labwareIndex] && this.messageStore[inputData.labwareIndex][inputData.address]
      && this.messageStore[inputData.labwareIndex][inputData.address][inputData.fieldName]) {
      let obj = this.messageStore[inputData.labwareIndex][inputData.address][inputData.fieldName]
      if (!$.isEmptyObject(obj)) {
        return obj
      }
    }
    return null
  }

  errorsForLabware(labwareIndex) {
    let errors = []
    for (var fieldName in this.messageStore[labwareIndex][null]) {
      errors = errors.concat(this.messageStore[labwareIndex][null][fieldName].errors)
    }
    return errors.filter((msg) => { return !!msg})
  }

  isEmpty() {
    return (Object.keys(this.messageStore).length == 0)
  }

  clearInput(inputData) {
    if (this.messageFor(inputData)!=null) {
      delete this.messageStore[inputData.labwareIndex][inputData.address][inputData.fieldName]
    }
  }

  /**
  * Private methods
  **/
  anyErrorsForLabwareIndex(labwareIndex) {
    return this.anyMessageForLabwareIndex(labwareIndex, 'errors')
  }


  anyWarningsForLabwareIndex(labwareIndex) {
    return this.anyMessageForLabwareIndex(labwareIndex, 'warnings')
  }

  anyMessageForLabwareIndex(labwareIndex, facility) {
    if (!this.messageStore[labwareIndex]) {
      return false
    }
    return Object.values(this.messageStore[labwareIndex]).map((obj) => { 
      return Object.values(obj)
    }).flat().some((dataError) => { 
      return ((!!dataError) && (!!dataError[facility])) ? (dataError[facility].length>0) : false
    })
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
        if (!this.messageStore[labwareIndex][address][fieldName][facility].includes(message[facility][fieldName])) {
          this.messageStore[labwareIndex][address][fieldName][facility].push(message[facility][fieldName])
        }
      }
    }
  }

  cleanErrors() {
    for (var labwareIndex in this.messageStore) {
      var labware = this.messageStore[labwareIndex]
      for (var address in labware) {
        var well = labware[address]
        for (var field in well) {
          var dataError = well[field]
          delete(dataError.errors)
        }
      }
    }
  }

  cleanErrorsWithoutAddress() {
    for (var labwareIndex in this.messageStore) {
      var labware = this.messageStore[labwareIndex]
      delete labware[null]
    }    
  }

  hasErrors() {
    for (var labwareIndex in this.messageStore) {
      var labware = this.messageStore[labwareIndex]
      for (var address in labware) {
        var well = labware[address]
        for (var field in well) {
          var dataError = well[field]
          if (dataError.errors) {
            return true
          }
        }
      }
    }
    return false
  }

}

export default MessageStore