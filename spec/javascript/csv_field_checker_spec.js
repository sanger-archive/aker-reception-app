import sinon from 'sinon';
import { assert } from 'chai';
import { validateCorrectPositions, validateNumberOfContainers } from 'csv_field_checker';

describe('CSVFieldChecker', () => {
  describe('#validateCorrectPositions', () => {

    let rows = {};
    const callFn = () => {
      return validateCorrectPositions(rows, 'position', 'plate_id');
    }

    context('when plate_id:well_position is not repeated', () => {

      beforeEach(() => {
        rows = [
          { plate_id: 'plate1', position: 'A:1' },
          { plate_id: 'plate1', position: 'B:1' },
          { plate_id: 'plate2', position: 'A:1' },
        ]
      })

      it('is true', () => {
        assert.isTrue(callFn())
      })
    })

    context('when plate_id:well_position is repeated', () => {

      beforeEach(() => {
        rows = [
          { plate_id: 'plate1', position: 'A:1' },
          { plate_id: 'plate1', position: 'B:1' },
          { plate_id: 'plate1', position: 'A:1' }
        ]
      })

      it('is false', () => {
        assert.isFalse(callFn())
      })
    })

    context('when plate_id:well_position is repeated (although cases differ)', () => {

      beforeEach(() => {
        rows = [
          { plate_id: 'Plate1', position: 'A:1' },
          { plate_id: 'plate1', position: 'B:1' },
          { plate_id: 'PlAtE1', position: 'A:1' }
        ]
      })

      it('returns false', () => {
        assert.isFalse(callFn())
      })
    })

  })

  describe('#valdiateNumberOfContainers', () => {

    let rows = {};
    let expectedNumberOfContainers;

    const callFn = () => {
      return validateNumberOfContainers(rows, 'plate_id', expectedNumberOfContainers)
    }

    context('when number of containers in Manifest matches expected', () => {

      beforeEach(() => {
        rows = [
          { plate_id: 'plate1', position: 'A:1' },
          { plate_id: 'plate1', position: 'B:1' },
          { plate_id: 'plate1', position: 'C:1' },
          { plate_id: 'plate2', position: 'A:1' },
          { plate_id: 'plate2', position: 'B:1' },
          { plate_id: 'plate2', position: 'C:1' },
          { plate_id: 'plate3', position: 'A:1' },
          { plate_id: 'plate3', position: 'B:1' },
          { plate_id: 'plate3', position: 'C:1' },
        ]

        expectedNumberOfContainers = 3
      })

      it('is true', () => {
        assert.isTrue(callFn())
      })

    })

    context('when number of containers in Manifest is more than expected', () => {

      beforeEach(() => {
        rows = [
          { plate_id: 'plate1', position: 'A:1' },
          { plate_id: 'plate2', position: 'A:1' },
          { plate_id: 'plate3', position: 'A:1' },
        ]

        expectedNumberOfContainers = 2
      })

      it('is false', () => {
        assert.isFalse(callFn())
      })

    })

    context('when number of containers in Manifest is fewer than expected', () => {

      beforeEach(() => {
        rows = [
          { plate_id: 'plate1', position: 'A:1' },
          { plate_id: 'plate2', position: 'A:1' },
        ]

        expectedNumberOfContainers = 3
      })

      it('is false', () => {
        assert.isFalse(callFn())
      })

    })

  })

})