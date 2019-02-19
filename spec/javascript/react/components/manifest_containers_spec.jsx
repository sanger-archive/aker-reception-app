import EnzymeHelper from '../enzyme_helper'

import React, { Fragment } from 'react';
import { expect } from 'chai'
import { shallow, mount } from 'enzyme';
import { createMockStore } from 'redux-test-utils';
import { Provider, connect } from 'react-redux'

import ManifestContainersConnected from "../../../../app/javascript/react/components/manifest_containers.jsx"

const getContext = (status) => {
  let context = { store: createMockStore(status) };
  return { context }
}

describe('<ManifestContainers />', () => {

  let status = {
    "services": {
      "materials_schema_url": "",
      "taxonomy_service_url": ""
    },
    "manifest": {
      "selectedTabPosition": "0",
      "manifest_id": "1234",
      "labwares": [
        {"supplier_plate_name": "Labware 1","positions": ["A:1","B:1"]},
        {"supplier_plate_name": "Labware 2","positions": ["1"]}
      ]
    },

    "content": {
      "structured": {
        "messages": [{
          "type": "warning",
          "display": "alert",
          "text": "There is an error in taxon id 1234"
        }],
        "labwares": {
          "1": {
            "addresses": {
              "1": {
                "fields": {}
              }
            }
          },
          "0": {
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
              },
              "B:1": {
                "row": 0,
                "changed": true,
                "invalid": false,
                "fields": {
                  "taxId": {
                    "changed": true,
                    "invalid": true,
                    "value": "4567",
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
      show_on_form: ['taxId', 'sampleName', 'tissue', 'groupId'],
      properties: {
        taxId: { friendly_name: "Taxon id", required: true},
        sampleName: { friendly_name: "Sample Name", required: true},
        tissue: { friendly_name: "Tissue", required: false},
        groupId: {friendly_name: "GroupId", required: false, allowed: ["C1", "C2"]}
      }
    }
  }

  context('when rendering it', () => {
    let wrapper = mount(<ManifestContainersConnected />, getContext(status))

    it('renders the ManifestContainersComponent element', () => {
      expect(wrapper.find('ManifestContainersComponent')).to.have.length(1)
    })

    it('<LabwareTabsComponent>', () => {
      it('renders the component', () => {
        expect(wrapper.find('LabwareTabsComponent')).to.have.length(1)
        expect(wrapper.find('LabwareTabs')).to.have.length(1)
      })
    })

    context('<LabwareTab>', () => {
      it('displays a tab for each labware', () => {
        expect(wrapper.find('LabwareTabComponent')).to.have.length(2)
      })

    })

    context('<LabwareContent>', () => {
      it('displays just the labware selected', () => {
        expect(wrapper.find('LabwareContentComponent')).to.have.length(1)
      })
    })

    context('<LabwareContentAddress>', () => {
      it('displays 2 positions', () => {
        expect(wrapper.find('LabwareContentComponent').first().find('LabwareContentAddressComponent')).to.have.length(2)
      })
      it('displays all the addresses', ()=> {
        (["A:1","B:1"]).forEach((val) => {
          expect(wrapper.find('LabwareContentAddressComponent').filterWhere((n) => n.prop('address')==val)).to.have.length(1)
        })

      })
    })

    context('<LabwareContentCell>', ()=>{
      it('displays 4 inputs for each address of the first labware', () => {
        const cells = wrapper.find('LabwareContentComponent').first().find('LabwareContentAddressComponent').first().find('LabwareContentCellComponent')
        expect(cells).to.have.length(4)
      })

      it('displays a value in a cell that should contain a value', () => {
        expect(wrapper.find('LabwareContentComponent').filterWhere((item) => {
          return (item.prop('labwareIndex') == 0)
        }).find('LabwareContentInputComponent').filterWhere((item) => {
          return ((item.prop('title') == "Taxon id") && (item.prop('selectedValue') == "1234"))
        })).to.have.length(1)
      })
    })

    context('<LabwareContentInput>', ()=>{
      let contextedWrapperFunction = (address, fieldName) => {
        return wrapper.find('LabwareContentAddressComponent').filterWhere((n) => {
          return n.prop('address')==address
        }).find('LabwareContentInputComponent').filterWhere((item) => {
          return (item.prop('title') == fieldName)
        })
      }
      context('when the field does not have a list of allowed values', ()=> {
        let contextedWrapper = contextedWrapperFunction("A:1", "Taxon id")

        it('shows an input', () => {
          expect(contextedWrapper.find('input')).to.have.length(1)
        })
        it('does not show a select', ()=>{
          expect(contextedWrapper.find('select')).to.have.length(0)
        })
      })
      context('when the field does have a list of allowed values', ()=> {
        let contextedWrapper = contextedWrapperFunction("A:1", "GroupId")

        it('shows a select', () => {
          expect(contextedWrapper.find('select')).to.have.length(1)
        })
        it('does not show an input', ()=>{
          expect(contextedWrapper.find('input')).to.have.length(0)
        })
      })
    })

  })
})
