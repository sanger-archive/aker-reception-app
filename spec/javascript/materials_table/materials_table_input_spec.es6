import sinon from 'sinon'
import {assert} from 'chai'
import MaterialsTableStore from 'materials_table/stores/materials_table_store'
import MessageStore from 'materials_table/stores/message_store'
import MaterialsTableInput from 'materials_table/materials_table_input'
import { JSDOM } from 'jsdom'

describe('MaterialsTableInput', function() {
  let obj = [{
    "labware_index": "1",
    "contents": {
      "A:1": {"donor_id": "234", "supplier_name": "abc1234"},
      "B:1": {"donor_id": "234", "supplier_name": "abc4567"}
    }
  }]
  let dom = new JSDOM(
  `
    <!DOCTYPE html>
    <html>
      <body>
        <a class='test1' href="#Labware1">Labware 1</a>
        <a class='test2' href="#Labware2">Labware 2</a>
        <input id='labware[1]address[A:1]fieldName[common_name]' type='hidden' value='SOME NEW VALUE' />
      <body>
    </html>
  `);
  const document = dom.window.document;

  beforeEach(function() {
    this.tab = document.querySelector('a.test1')
    this.input = document.querySelector('input')
    let tableStore = new MaterialsTableStore(obj)
    let messageStore = new MessageStore()
    this.tableInput = new MaterialsTableInput(this.input, this.tab, tableStore, messageStore)
  })

})