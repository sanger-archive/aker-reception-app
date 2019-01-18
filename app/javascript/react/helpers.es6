export const allRequiredFields = (providedProps) => {
  return Object.keys(providedProps.schema.properties).filter((prop) => {
    return providedProps.schema.properties[prop].required === true
  })
}
export const allMatchedFields = (providedProps) => {
  return Array.from(new Set(providedProps.mapping.matched.map(obj => obj.expected)))
}
export const allRequiredUnmatchedFields = (providedProps) => {
  const matchedFields = new Set(allMatchedFields(providedProps))
  return (allRequiredFields(providedProps).filter(elem => !matchedFields.has(elem)))
}
export const isThereAnyRequiredUnmatchedField = (providedProps) => {
  if (!providedProps.schema) {
    return true
  }
  return (allRequiredUnmatchedFields(providedProps).length > 0)
}
