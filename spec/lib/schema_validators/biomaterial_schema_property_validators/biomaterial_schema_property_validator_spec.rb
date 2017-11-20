require 'rails_helper'

require 'schema_validators'

RSpec.describe SchemaValidators::BiomaterialSchemaPropertyValidators::BiomaterialSchemaPropertyValidator do
  let(:validator) { double('validator') }
  let(:prop_data) { {'common_name': 'a common name', 'supplier_name': '   some text copied from excel    ', 'decription': ''}.as_json  }
  let(:prop_name) { 'scientific name' }
  let(:prop_validator) { 
    SchemaValidators::BiomaterialSchemaPropertyValidators::BiomaterialSchemaPropertyValidator.new(validator, prop_name, prop_data) 
  }

  context '#field_data_for_property' do
    it 'returns the property value if the value is not empty' do
      expect(prop_validator.field_data_for_property('common_name', prop_data)).to eq('a common name')
    end
    it 'returns the property value without whitespaces at both sides' do
      expect(prop_validator.field_data_for_property('supplier_name', prop_data)).to eq('some text copied from excel')
    end
    it 'returns the property value without whitespaces at both sides' do
      expect(prop_validator.field_data_for_property('decription', prop_data)).to eq(nil)
    end    
  end

  context '#error_messages' do
    it 'returns the error messages of the schema validator' do
      expect(validator).to receive(:error_messages)
      prop_validator.error_messages
    end
  end

  context '#add_error' do
    context 'when adding an error to the slot of a labware that already exists' do
      let(:errors) {
        [
          {labwareIndex: 1, address: '1', errors: {}},
          {labwareIndex: 1, address: '2', errors: {}},
          {labwareIndex: 2, address: '1', errors: {}}
        ]
      }
      it 'adds the error in the corresponding element of the list of errors' do
        allow(validator).to receive(:error_messages).and_return(errors)

        prop_validator.add_error(1, '2', 'common_name', 'a message')
        prop_validator.add_error(1, '2', 'supplier_name', 'a message')
        
        expect(errors[0][:errors].keys.length).to eq(2)
        expect(errors[1][:errors].keys.length).to eq(0)
        expect(errors[2][:errors].keys.length).to eq(0)
      end
    end
    context 'when either the slot does not exist' do
      it 'creates a new error element' do
      end
    end
  end
end