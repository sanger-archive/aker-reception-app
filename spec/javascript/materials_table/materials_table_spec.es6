import sinon from 'sinon'
import {assert} from 'chai'
import MaterialsTableStore from 'materials_table/stores/materials_table_store'
import MessageStore from 'materials_table/stores/message_store'
import MaterialsTable from 'materials_table/materials_table'
import { JSDOM } from 'jsdom'

describe('MaterialsTable', function() {
  let params = [{
    "labware_index": "1",
    "contents": {
      "A:1": {"donor_id": "234", "supplier_name": "abc1234"},
      "B:1": {"donor_id": "234", "supplier_name": "abc4567"}
    }
  },{
    "labware_index": "2",
    "contents": {
      "A:1": {"donor_id": "234", "supplier_name": "abc1234"},
      "B:1": {"donor_id": "234", "supplier_name": "abc4567"}
    }
  }
  ]
  let dom = new JSDOM(
  `
    <!DOCTYPE html>
    <html>
      <body>
        <form>
          <a data-toggle="tab" class='test1' id='labware_tab1' href="#Labware1">Labware 1</a>
          <a data-toggle="tab" class='test2' id='labware_tab2' href="#Labware2">Labware 2</a>
          <input id='labware[1]address[A:1]fieldName[common_name]' type='hidden' value='SOME NEW VALUE' />
        </form>
      <body>
    </html>
  `);
  const document = dom.window.document;

  beforeEach(function() {
    this.node = document.querySelector('body')
    this.tableTab = new MaterialsTable(this.node, params)
  })

  context('#tabs', function() {
    it('returns the tabs', function() {
      assert.isOk(this.tableTab)
    })
  })  
})