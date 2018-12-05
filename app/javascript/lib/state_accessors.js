export const StateAccessors = (state) => {
  const ACCESSORS =  {
    manifest: {
      selectedTabPosition: () => {
        if (!state || !state.manifest) {
          return -1
        }
        return parseInt(state.manifest.selectedTabPosition, 10)
      },
      labwareAtIndex: (labwareIndex) => {
        return state.manifest.labwares[labwareIndex]
      },
      labwaresForManifest: () => {
        if (!state || !state.manifest) {
          return []
        }
        if (state.manifest.labwares instanceof Object) {
          return Object.keys(state.manifest.labwares).reduce((memo, key) => {
            memo[key] = state.manifest.labwares[key]
            return memo
          }, [])
        }
        return state.manifest.labwares || []
      },
      plateIdFor: (labwareIndex) => {
        return state.manifest.labwares[labwareIndex].supplier_plate_name
      },
    },
    content: {
      classToShowForInput: (labwareIndex, address, fieldName) => {
        let anyError = false
        const messages = ACCESSORS.content.messages().filter((m) => {
          if ((m.labware_index == labwareIndex) && (m.address == address) && (m.field==fieldName)) {
            anyError = (anyError || (!ACCESSORS.content.isWarning(m)))
            return true
          }
          return false
        })
        if (messages.length > 0) {
          return (anyError ? "has-error" : "has-warning")
        } else {
          return ""
        }
      },
      hasMessages: (labwareIndex) => {
        return (ACCESSORS.content.messages(labwareIndex).length > 0)
      },
      hasErrors: (labwareIndex) => {
        return (ACCESSORS.content.errorMessages(labwareIndex).length > 0)
      },
      classToShowForTab: (labwareIndex) => {
        return
      },
      isWarning: (m) => { return (m.level == 'WARN')},
      warningMessages: (tabIndex) => {
        return ACCESSORS.content.messages(tabIndex).filter((m) => ACCESSORS.content.isWarning(m))
      },
      errorMessages: (tabIndex) => {
        return ACCESSORS.content.messages(tabIndex).filter((m) => !ACCESSORS.content.isWarning(m))
      },
      messages: (tabIndex) => {
        let list = (state?.content?.structured?.messages || [])
        if (!tabIndex) {
          return list
        } else {
          return list.filter((m) => { return m.labware_index==tabIndex})
        }
      },
      selectedValueAtCell: (labwareId, address, fieldName) => {
        const val = state?.content?.structured?.labwares?.[labwareId]?.addresses?.[address]?.fields?.[fieldName]?.value
        return (val ? val : "")
      },
      setValueAtCell: (labwareId, address, fieldName, value) => {
        let obj = ['content', 'structured', 'labwares', labwareId, 'addresses', address, 'fields', fieldName].reduce((memo, key) => {
          if (!memo[key]) {
            memo[key] = {}
          } /*else {
            memo[key] = Object.assign({}, memo[key])
          }*/
          return memo[key]
        }, Object.assign({}, state))
        obj.value = value
        return obj
      }
    },
    schema: {
      fieldsToShow: () => {
        return state.schema.show_on_form || []
      },
      friendlyNameFor: (fieldName) => {
        return (state.schema.properties[fieldName].friendly_name || fieldName)
      },
      isRequiredField: (fieldName) => {
        return ACCESSORS.schema.propertyForFieldName(fieldName)["required"]
      },
      propertyForFieldName: (fieldName) => {
        return state.schema["properties"][fieldName]
      },
      fieldTypeFor: (fieldName)=> {
        return (state.schema["properties"][fieldName]["field_type"] || 'text')
      },
      fieldNameForPos: (pos) => {
        return state.schema.show_on_form[pos]
      },
      isSelectFieldName: (fieldName) => {
        return !!ACCESSORS.schema.optionsForSelect(fieldName)
      },
      optionsForSelect: (fieldName) => {
        return state.schema.properties[fieldName]['allowed']
      },
      selectedOptionValue: (fieldName, selectedValue) => {
        if ((!selectedValue) || (selectedValue.length==0)) {
          return ""
        }
        return ACCESSORS.schema.optionsForSelect(fieldName).filter((o) => {
          return o.match(new RegExp(selectedValue, 'i'))
        })[0] || ""
      }
    }
  }
  return ACCESSORS
}
