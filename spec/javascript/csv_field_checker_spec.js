import sinon from 'sinon'
import {assert} from 'chai'
import 'csv_field_checker.js'

describe('CSVFieldChecker', () => {
  context('#validateCorrectPositions', () => {
    it('validates when the positions are not repeated', () => {
      assert.isOk(CSVFieldChecker.validateCorrectPositions({
        data: [['A:1', 'Some data'],['B:1', 'some other data']]
      }))
    })  
    it('does not validate when it has positions that are repeated', () => {
      assert.isNotOk(CSVFieldChecker.validateCorrectPositions({
        data: [['A:1', 'Some data'],['B:1', 'some other data'], ['A:1', 'Some data']]
      }))
    })
  })
})