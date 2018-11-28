export const StateAccessors = (state) => {
  const ACCESSORS =  {
    manifest: {
      labwareAtIndex: (labwareIndex) => {
        return state.manifest.labwares[labwareIndex]
      },
      labwaresForManifest: () => {
        return state.manifest.labwares || []
      }
    },
    content: {
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
