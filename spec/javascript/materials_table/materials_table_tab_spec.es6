import sinon from 'sinon'
import {assert} from 'chai'
import MaterialsTableStore from 'materials_table/stores/materials_table_store'
import MessageStore from 'materials_table/stores/message_store'
import MaterialsTableTab from 'materials_table/materials_table_tab'
import { JSDOM } from 'jsdom'

describe('MaterialsTableTab', function() {
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
        <a class='test1' id='labware_tab1' href="#Labware1">Labware 1</a>
        <a class='test2' id='labware_tab2' href="#Labware2">Labware 2</a>
        <input id='labware[1]address[A:1]fieldName[common_name]' type='hidden' value='SOME NEW VALUE' />
      <body>
    </html>
  `);
  const document = dom.window.document;

  beforeEach(function() {
    this.tab = document.querySelector('a.test1')
    this.tableStore = new MaterialsTableStore(obj)
    this.messageStore = new MessageStore()
    this.tableTab = new MaterialsTableTab(this.tab, this.tableStore, this.messageStore)
  })

  context('#isTabWithContent', function() {
    it('returns true if the tab has content stored', function() {
      assert.isOk(this.tableTab.isTabWithContent())
    })
    it('returns false if the tab does not have content', function() {
      let tab2 = document.querySelector('a.test2')
      let anotherTableTab = new MaterialsTableTab(tab2, this.tableStore, this.messageStore)
      assert.isNotOk(anotherTableTab.isTabWithContent())
    })
  })  
})