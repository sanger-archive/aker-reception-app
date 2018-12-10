import EnzymeHelper from '../enzyme_helper'

import React, { Fragment } from 'react';
import { expect } from 'chai'
import { shallow, mount } from 'enzyme';
import ManifestEditor from "../../../app/javascript/components/manifest_editor.jsx"
import { ManifestEditorComponent } from "../../../app/javascript/components/manifest_editor.jsx"

import { createMockStore } from 'redux-test-utils';

const getContext = (status) => {
  let context = { store: createMockStore(status) };
  return { context }
}

let status = {
  "manifest": {
    "selectedTabPosition": "0",
    "manifest_id": "1234",
    "labwares": [
      {"supplier_plate_name": "Labware 1","positions": ["A:1","B:1"]},
      {"supplier_plate_name": "Labware 2","positions": ["1"]}
    ]
  },
  mapping: { expected: [], observed: [], matched: []}
}


describe('<ManifestEditor />', () => {
  context('when rendering it', () => {
    let wrapper = shallow(<ManifestEditor />, getContext(status));
    it('renders the Provider element', () => {
      expect(wrapper.find('Provider')).to.have.length(1);
    })
    it('renders the ManifestEditorConnected element', () => {
      expect(wrapper.find('ManifestEditorComponent')).to.have.length(1);
    })

  })
})

describe('<ManifestEditorComponent>', () => {
  context('when rendering it', () => {
    let wrapper = mount(<ManifestEditor />, getContext(status));

    it('renders the MappingTool element', () => {
      expect(wrapper.find('MappingToolComponent')).to.have.length(1);
    })
  })
})

