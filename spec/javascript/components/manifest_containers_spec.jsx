import EnzymeHelper from '../enzyme_helper'

import React, { Fragment } from 'react';
import { expect } from 'chai'
import { shallow, mount } from 'enzyme';
import { createMockStore } from 'redux-test-utils';

import ManifestContainers from "../../../app/javascript/components/manifest_containers.jsx"

const getContext = (status) => {
  let context = { store: createMockStore(status) };
  return { context }
}

describe('<ManifestContainers />', () => {

  let status = {
    "contents": {
      "structured": {
        "messages": [{
          "type": "warning",
          "display": "alert",
          "text": "There is an error in taxon id 1234"
        }],
        "labwares": {
          "Labware 1": {
            "messages": [{
              "type": "warning",
              "display": "alert",
              "text": "This labware is wrong"
            }],
            "changed": true,
            "invalid": false,
            "addresses": {
              "A:1": {
                "row": 0,
                "changed": true,
                "invalid": false,
                "fields": {
                  "taxId": {
                    "changed": true,
                    "invalid": true,
                    "value": "1234",
                    "messages": [{"type": "warning", "display": "tooltip", "text": "taxon id is wrong"}]
                  }
                }
              }
            }
          }
        }
      },
      "raw": [
        {"plateId": "Labware 1", "address": "A:1", "taxId": "1234", "sampleName": "STD1234"},
        {"plateId": "Labware 1", "address": "B:1", "taxId": "1234", "sampleName": "STD1234"},
        {"plateId": "Labware 2", "address": "A:1", "taxId": "1234", "sampleName": "STD1234"}
      ]
    },
    schema: {
      properties: {
        taxId: { friendly_name: "Taxon id", required: true},
        sampleName: { friendly_name: "Sample Name", required: true},
        tissue: { friendly_name: "Tissue", required: false},
        phenotype: { friendly_name: "Phenotype", required: false},
      }
    }
  }

  context('when rendering it', () => {
    let wrapper = mount(<ManifestContainers />, getContext(status))
    it('renders the MappingInterface element', () => {
      expect(wrapper.find('MappingInterface')).to.have.length(1)
    })
    it('renders the MappedFieldsList element', () => {
      expect(wrapper.find('MappedFieldsList')).to.have.length(1)
    })
    it('renders the list of fields mapped from the status', () => {
      expect(wrapper.find('MappedFieldsList').find('MappedPairs').find('tr')).to.have.length(2)
    })
    it('renders the MappingInterface element', () => {
      expect(wrapper.find('MappingInterface')).to.have.length(1)
    })
    it('renders the list of observed fields', () => {
      expect(wrapper.find('MappingInterface').find('ExpectedMappingOptions').find('option')).to.have.length(2)
    })
    it('renders the list of expected fields', () => {
      expect(wrapper.find('MappingInterface').find('ObservedMappingOptions').find('option')).to.have.length(3)
    })
  })
})
