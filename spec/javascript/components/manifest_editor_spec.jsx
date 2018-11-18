import EnzymeHelper from '../enzyme_helper'

import React, { Fragment } from 'react';
import { expect } from 'chai'
import { shallow, mount } from 'enzyme';
import ManifestEditor from "../../../app/javascript/components/manifest_editor.jsx"
import { ManifestEditorConnected } from "../../../app/javascript/components/manifest_editor.jsx"

import { createMockStore } from 'redux-test-utils';

const getContext = (status) => {
  let context = { store: createMockStore(status) };
  return { context }
}

let status = {
  mapping: { expected: [], observed: [], matched: []}
}

describe('<ManifestEditor />', () => {
  context('when rendering it', () => {
    let wrapper = shallow(<ManifestEditor />, getContext(status));
    it('renders the Provider element', () => {
      expect(wrapper.find('Provider')).to.have.length(1);
    })
    xit('renders the ManifestEditorConnected element', () => {
      expect(wrapper.find('ManifestEditorConnected')).to.have.length(1);
    })

  })
})

describe('<ManifestEditorConnected>', () => {
  context('when rendering it', () => {
    let wrapper = shallow(<ManifestEditorConnected />, getContext(status));

    xit('renders the MappingTool element', () => {
      expect(wrapper.find('MappingTool')).to.have.length(1);
    })
  })
})
