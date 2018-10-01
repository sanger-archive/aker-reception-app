import sinon from 'sinon'
import {assert} from 'chai'
import MaterialsTableStore from 'materials_table/stores/materials_table_store'
import { JSDOM } from 'jsdom'

describe('MaterialsTableStore', function() {
  let obj = [{
    "labware_index": "1",
    "contents": {
      "A:1": {"donor_id": "234", "supplier_name": "abc1234"},
      "B:1": {"donor_id": "234", "supplier_name": "abc4567"}
    }
  }]
  let dom = new JSDOM(
  `
    <!DOCTYPE html><html>
      <body>
        <a class='test1' href="#Labware1">Labware 1</a>
        <a class='test2' href="#Labware2">Labware 2</a>
        <input type='hidden' value='SOME NEW VALUE' />
      <body>
    </html>
  `);
  const document = dom.window.document;

  beforeEach(function() {
    this.store = new MaterialsTableStore(obj)
  })

  context('#dataForTab', function() {
    it('gets the data store for a tab', function() {
      let tab = document.querySelector("a.test1")
      assert.isOk(this.store.dataForTab(tab))
    })
    it('returns null if there is no data store for the tab', function() {
      let tab2 = document.querySelector("a.test2")
      assert.equal(this.store.dataForTab(tab2), null)
    })
  })

  context('#getValueForInput', function() {
    it('returns the value for a field from the materials store', function() {
      let tab = document.querySelector("a.test1")
      assert.equal(this.store.getValueForInput({address: 'A:1', tab, fieldName: 'supplier_name'}), 'abc1234')
    })
    it('returns null if there is no value for the field', function() {
      let tab = document.querySelector("a.test1")
      assert.equal(this.store.getValueForInput({address: 'A:1', tab, fieldName: 'common_name'}), null)
    })    
    it('returns null if there is no store', function() {
      let tab = document.querySelector("a.test2")
      assert.equal(this.store.getValueForInput({address: 'A:1', tab, fieldName: 'supplier_name'}), null)
    })        
  })

  context('#setValueForInput', function() {
    beforeEach(function() {
      this.input = document.querySelector('input')
    })
    it('saves the value from the input into the materials store', function() {
      let tab = document.querySelector("a.test1")
      let refer = {input: this.input, labwareIndex: 1, address: 'A:1', tab, fieldName: 'supplier_name'}
      this.store.setValueForInput(refer)
      assert.equal(this.store.getValueForInput(refer), 'SOME NEW VALUE')
    })

  })
})
