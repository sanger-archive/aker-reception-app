import { expect } from 'chai'
import {
  allRequiredFields,
  allMatchedFields,
  allRequiredUnmatchedFields,
  isThereAnyRequiredUnmatchedField
} from "helpers"

describe('with helper functions', () => {
  let providedProps = {
    mapping: {
      expected: [
        'tissue',
        'phenotype'],
      observed: ['Tissue', 'concentration', 'volume'],
      matched: [
        {expected: 'taxId', observed: 'taxonomy id'},
        {expected: 'sampleName', observed: 'samplename'}
      ]
    },
    schema: {
      properties: {
        taxId: { friendly_name: "Taxon id", required: true},
        sampleName: { friendly_name: "Sample Name", required: true},
        tissue: { friendly_name: "Tissue", required: true},
        phenotype: { friendly_name: "Phenotype", required: true},
      }
    }
  }

  context('#allRequiredFields()', () => {
    context('when provided an state', () => {
      it('returns the list of required fields', () => {
        expect(
          JSON.stringify(allRequiredFields(providedProps))
        ).to.eq(JSON.stringify(['taxId', 'sampleName', 'tissue', 'phenotype']))
      })
    })
  })
  context('#allMatchedFields()', () => {
    context('when provided an state', () => {
      it('returns the list of matched fields', () => {
        expect(
          JSON.stringify(allMatchedFields(providedProps))
        ).to.eq(JSON.stringify(['taxId', 'sampleName']))
      })
    })
  })
  context('#allRequiredUnmatchedFields()', () => {
    context('when provided an state', () => {
      it('returns the list of matched fields', () => {
        expect(
          JSON.stringify(allRequiredUnmatchedFields(providedProps))
        ).to.eq(JSON.stringify(['tissue', 'phenotype']))
      })
    })
  })
  context('#isThereAnyRequiredUnmatchedField()', () => {
    context('when provided an state', () => {
      it('returns the list of matched fields', () => {
        expect(isThereAnyRequiredUnmatchedField(providedProps)).to.eq(true)
      })
    })
  })
})
