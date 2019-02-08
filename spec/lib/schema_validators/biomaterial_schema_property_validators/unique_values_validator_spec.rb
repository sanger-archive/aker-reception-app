require 'rails_helper'

RSpec.describe SchemaValidators::BiomaterialSchemaPropertyValidators::UniqueValuesValidator do
  let(:schema) {
    obj={}
    obj['properties'] = {}
    obj['properties']['myprop'] = prop_data
    obj
  }
  let(:validator) { SchemaValidators::BiomaterialSchemaValidator.new(schema) }
  let(:prop_name) { 'myprop' }
  let(:class_name) { SchemaValidators::BiomaterialSchemaPropertyValidators::UniqueValuesValidator }

  context 'self.is_applicable' do

    context 'when the property \'unique_value\' is set to true' do
      let(:prop_data) { { 'description': '', 'unique_value': true }.as_json }

      it 'is applicable' do
        expect(class_name.is_applicable?(prop_name, prop_data)).to eq(true)
      end
    end
    context 'when the property \'unique_value\' is set to false' do
      let(:prop_data) { { 'description': '', 'unique_value': false }.as_json }

      it 'is not applicable' do
        expect(class_name.is_applicable?(prop_name, prop_data)).to eq(false)
      end
    end

    context 'when the property \'unique_value\' is not defined' do
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
      #allow(prop_validator).to receive(:add_error)
    end

    let(:prop_data) { { 'description': '', 'unique_value': true }.as_json }
    context 'when there are duplicate values in the same labware' do
      it 'returns empty warnings in the first validation (no duplicated found yet)' do
        prop_validator.validate(1, 'A:1', bio_data)
        expect(prop_validator.warning_messages.empty?).to eq(true)
      end
      it 'returns warnings in next validations' do
        prop_validator.validate(1, 'A:1', bio_data)
        expect(prop_validator.warning_messages.empty?).to eq(true)
        prop_validator.validate(1, 'B:1', bio_data)
        expect(prop_validator.warning_messages.empty?).to eq(false)
      end
    end
    context 'when there are duplicate values but they are not in the same labware' do
      it 'returns false' do
        prop_validator.validate(1, 'A:1', bio_data)
        expect(prop_validator.warning_messages.empty?).to eq(true)
        prop_validator.validate(2, 'B:1', bio_data)
        expect(prop_validator.warning_messages.empty?).to eq(false)
      end
    end
    context 'when there are no duplicates' do
      it 'returns true' do
        prop_validator.validate(1, 'A:1', bio_data)
        expect(prop_validator.warning_messages.empty?).to eq(true)
        prop_validator.validate(1, 'B:1', another_bio_data)
        expect(prop_validator.warning_messages.empty?).to eq(true)
      end
    end
  end
end
