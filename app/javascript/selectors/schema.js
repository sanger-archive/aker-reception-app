import { createSelector } from 'reselect'

export const SchemaSelector = {
  get: createSelector(
    (state) => JSON.stringify(state.schema),
    (schema) => JSON.parse(schema)
  ),
  fieldsToShow: createSelector(
    (state) => SchemaSelector.get(state),
    (schema) => { return schema.show_on_form || [] }
  ),
  propertyForFieldName: (state, fieldName) => SchemaSelector.get(state).properties[fieldName],
  friendlyNameFor: createSelector(
    (state, fieldName) => SchemaSelector.propertyForFieldName(state, fieldName),
    (property) => property["friendly_name"]
  ),
  isRequiredField: createSelector(
    (state, fieldName) => SchemaSelector.propertyForFieldName(state, fieldName),
    (property) => property["required"]
  ),
  fieldTypeFor: createSelector(
    (state, fieldName) => SchemaSelector.propertyForFieldName(state, fieldName),
    (property) => { return property["field_type"] || 'text'}
  ),
  fieldNameForPos: (state, pos) => SchemaSelector.fieldsToShow(state)[pos],
  isSelectFieldName: (state, fieldName) => !!SchemaSelector.optionsForSelect(state, fieldName),
  optionsForSelect: createSelector(
    (state, fieldName) => SchemaSelector.propertyForFieldName(state, fieldName),
    (property) => property['allowed']
  ),
  selectedOptionValue: createSelector(
    [
      (state, fieldName) => SchemaSelector.optionsForSelect(state, fieldName),
      (state, fieldName, selectedValue) => selectedValue
    ],
    (options, selectedValue) => {
      return (options.filter((o) => o.match(new RegExp('^'+selectedValue+'$', 'i')))[0] || "")
    }
  )
}

export default SchemaSelector
