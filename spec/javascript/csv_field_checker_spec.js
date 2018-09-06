import sinon from 'sinon'
import {assert} from 'chai'
import {validateCorrectPositions } from 'csv_field_checker'

describe('CSVFieldChecker', () => {
  context('#validateCorrectPositions', () => {
    it('validates when the positions are not repeated', () => {
      assert.isOk(validateCorrectPositions({
        data: [{position: 'A:1', name: 'Some data'},{position: 'B:1', name: 'some other data'}]
      }, 'position'))
    })  
    it('does not validate when it has positions that are repeated', () => {
      assert.isNotOk(validateCorrectPositions({
        data: [{position: 'A:1', name: 'Some data'},{position: 'B:1', name: 'some other data'}, 
        {position: 'A:1', name: 'Some data'}]
      }, 'position'))
    })
  })
})