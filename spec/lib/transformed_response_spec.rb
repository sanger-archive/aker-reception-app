require 'rails_helper'

RSpec.describe TransformedResponse do

  let(:transformed_response) { TransformedResponse.new(transformer: transformer) }

  describe '#initialization' do

    context 'when transformer is not provided' do

      it 'raises an error' do
        expect { TransformedResponse.new }.to raise_error(KeyError)
      end

    end

  end

  describe '#response' do

    context 'when transformation is successful' do

      let(:transformer) { double("Transformer", transform: true, contents: 'some csv data') }

      it 'has status set to :ok' do
        expect(transformed_response.response[:status]).to eql(:ok)
      end

      it 'has json with contents' do
        expect(transformed_response.response[:json][:contents]).to eql('some csv data')
      end
    end

    context 'when transformation is not successful' do

      let(:errors) { double("Errors", full_messages: "Some helpful error messages") }
      let(:transformer) { double("Transformer", transform: false, errors: errors) }

      it 'has status set to :unprocessable_entity' do
        expect(transformed_response.response[:status]).to eql(:unprocessable_entity)
      end

      it 'has json with errors' do
        expect(transformed_response.response[:json][:contents]).to be_nil
        expect(transformed_response.response[:json][:errors]).to eql('Some helpful error messages')
      end
    end

  end

end