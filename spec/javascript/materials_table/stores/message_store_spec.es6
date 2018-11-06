import sinon from 'sinon'
import {assert} from 'chai'
import MessageStore from 'materials_table/stores/message_store'

describe('MessageStore', function() {

  // {
  //   "manifest": {
  //     "name": "manifest 1",
  //     "type": "Manifest",
  //     "attributes": {
  //       "errors": "",
  //       "loading": true,
  //       "mappingTool": {
  //         "shown": true,
  //         "validMatchedFields": true,
  //         "fieldsMatched": [
  //           {
  //             "leftField": "suppplier_name",
  //             "RightField": "supplier_name"
  //           }
  //         ],
  //         "leftFieldsUnmatched": [],
  //         "rightFieldsUnmatched": []
  //       }
  //     },
  //     "contents": {
  //       "labware_1": {
  //         "id": "1234",
  //         "type": "Tab",
  //         "attributes": {
  //           "hasError": "true",
  //           "hasWarning": "false",
  //           "errors": [],
  //           "warnings": []
  //         },
  //         "validations": [{
  //           "type": "CheckLabware",
  //           "attributes": {
  //             "event": "leaveTab",
  //             "status": "valid"
  //           }
  //         }]
  //         "contents": {
  //           "A:1": {
  //             "type": "Address",
  //             "attributes": {
  //               "column": "1",
  //               "row": "A",
  //               "hasError": "true",
  //               "hasWarning": "false",
  //               "errors": [{
  //                 "id": "4",
  //                 "msg": "bla bla",
  //                 "type": "alert"
  //                 "facility": "error",
  //                 "level": "debug"
  //               }],
  //               "warnings": []
  //             },
  //             "validations": [
  //               {
  //                 "type": "CheckRow"
  //                 "attributes": {
  //                   "event": "leaveRow",
  //                   "status": "failed"
  //                 }
  //               }
  //             ],
  //             "contents": {
  //               "supplier_name": {
  //                 "type": "Field",
  //                 "attributes": {
  //                   "readonly": "true",
  //                   "editable": "true",
  //                   "loading": "false",
  //                   "errors": "My error string",
  //                   "warnings": "My error string",
  //                   "placeholder": "",
  //                   "hasError": "false",
  //                   "hasWarning": "true",
  //                   "value": "1234"
  //                 },
  //                 "validations": [
  //                   {
  //                     "type": "RegexpMatching",
  //                     "event": "blur",
  //                     "attributes": {
  //                       "id": "1234"
  //                       "regexp": "1234",
  //                       "status":"failed",
  //                       //"dependentMessages": ["4","33"]
  //                       //"relatedValidations": ["1234", "4453"]
  //                     }
  //                   },
  //                   {
  //                     "type": "Uniqueness"
  //                     "column": "1"
  //                     "status":"failed",
  //                     "relatedWith": []
  //                   },
  //                   {
  //                     "type": "RequiredValue"
  //                   },
  //                   {
  //                     "type": "AllowedValues"
  //                   },
  //                   {
  //                     "type": "HMDMC"
  //                   },
  //                   {
  //                     "type": "TaxonomyValid"
  //                   }
  //                 ],
  //               }
  //             }
  //           }
  //         }
  //       ]
  //     }
  //   }
  // }

  let messageData = {
    "update_successful":false,"labwares_indexes":[1,2],
    "messages":[
      {
        "errors":{"supplier_name":"At least one material must be specified for each item of labware"},
        "labwareIndex":2,"address":null,"update_successful":false
      },
      {
        "errors":{"common_name":"This material does not have any common name"},
        "warnings":{"common_name":"It should be uppercased"},
        "labwareIndex":2,"address":"A:1","update_successful":false
      }
    ]
  }
  beforeEach(function() {
    this.store = new MessageStore()
  })
  context('#loadMessages', function() {
    it('stores a valid message', function() {
      assert.isOk(this.store.loadMessages(messageData))
    })
  })
  context('#isEmpty', function() {
    it('returns true if the store is empty', function() {
      assert.isOk(this.store.isEmpty())
    })
    it('returns false when the store is not empty', function() {
      this.store.loadMessages(messageData)
      assert.isNotOk(this.store.isEmpty())
    })
  })
  context('#messageFor', function() {
    it('returns null if there is no message matching the provided params', function() {
      let message = this.store.messageFor({labwareIndex: 2, address: 'A:1', fieldName: 'common_name'})
      assert.equal(message, null)
    })
    it('gives back the message for the specified labware, address and field', function() {
      this.store.loadMessages(messageData)
      let message = this.store.messageFor({labwareIndex: 2, address: 'A:1', fieldName: 'common_name'})
      assert.equal(message.errors[0], "This material does not have any common name")
    })
    it('allows null as a valid address', function() {
      this.store.loadMessages(messageData)
      let message = this.store.messageFor({labwareIndex: 2, address: null, fieldName: 'supplier_name'})
      assert.equal(message.errors[0], "At least one material must be specified for each item of labware")
    })
    it('can have errors and warnings for the same field name', function() {
      this.store.loadMessages(messageData)
      let message = this.store.messageFor({labwareIndex: 2, address: 'A:1', fieldName: 'common_name'})
      assert.equal(message.errors[0], "This material does not have any common name")
      assert.equal(message.warnings[0], "It should be uppercased")
    })
  })
})
