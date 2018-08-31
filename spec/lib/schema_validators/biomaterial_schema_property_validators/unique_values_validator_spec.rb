require 'rails_helper'

RSpec.describe SchemaValidators::BiomaterialSchemaPropertyValidators::UniqueValuesValidator do
  let(:validator) { double('validator') }
  let(:prop_name) { 'myprop' }
  let(:class_name) { SchemaValidators::BiomaterialSchemaPropertyValidators::UniqueValuesValidator }

  context 'self.is_applicable' do

    context 'when the property \'unique\' is set to true' do
      let(:prop_data) { { 'description': '', 'unique': true }.as_json }

      it 'is applicable' do
        expect(class_name.is_applicable?(prop_name, prop_data)).to eq(true)
      end
    end
    context 'when the property \'unique\' is set to false' do
      let(:prop_data) { { 'description': '', 'unique': false }.as_json }

      it 'is not applicable' do
        expect(class_name.is_applicable?(prop_name, prop_data)).to eq(false)
      end
    end

    context 'when the property \'unique\' is not defined' do
      let(:prop_data) { { 'description': '' }.as_json }

      it 'is not applicable' do
        expect(class_name.is_applicable?(prop_name, prop_data)).to eq(false)
      end
    end
  end
  context '#validate' do
    
    let(:bio_data) { {'myprop': '333'}.as_json }
    let(:another_bio_data) { {'myprop': '4444'}.as_json }
    let(:prop_validator) { 
      class_name.new(validator, prop_name, prop_data) 
    }
    before do
      allow(prop_validator).to receive(:add_error)
    end

    let(:prop_data) { { 'description': '', 'unique': true }.as_json }
    context 'when there are duplicate values in the same labware' do
      it 'returns true in the first validation (no dupicated found yet)' do
        expect(prop_validator.validate(1, 'A:1', bio_data)).to eq(true)
      end
      it 'returns false in next validations' do
        expect(prop_validator.validate(1, 'A:1', bio_data)).to eq(true)
        expect(prop_validator.validate(1, 'B:1', bio_data)).to eq(false)
      end
    end
    context 'when there are duplicate values but they are not in the same labware' do
      it 'returns false' do
        expect(prop_validator.validate(1, 'A:1', bio_data)).to eq(true)
        expect(prop_validator.validate(2, 'B:1', bio_data)).to eq(false)
      end        
    end
    context 'when there are no duplicates' do
      it 'returns true' do
        expect(prop_validator.validate(1, 'A:1', bio_data)).to eq(true)
        expect(prop_validator.validate(1, 'B:1', another_bio_data)).to eq(true)          
      end        
    end
  end
end