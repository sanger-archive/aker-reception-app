require 'rails_helper'

RSpec.describe Transformers::ExcelToCsv do

  let(:transformer) { Transformers::ExcelToCsv.new(path: path) }

  describe '#initialization' do

    context 'when path is not provided' do
      it 'raises an error' do
        expect { Transformers::ExcelToCsv.new(plath: 'ooops') }.to raise_error(KeyError)
      end
    end

  end

  describe '#transform' do

    context 'when file can not be found' do
      let(:path) { '/fake/path/to/spreadsheet.xlsx' }

      it 'returns false' do
        expect(transformer.transform).to be false
      end

      it 'sets an error' do
        transformer.transform
        expect(transformer.errors.full_messages).to eq(["File could not be found."])
      end

    end

    context 'when file is the wrong format' do
      let(:path) { 'spec/fixtures/files/WorkOrderJobSets.png' }

      it 'returns false' do
        expect(transformer.transform).to be false
      end

      it 'sets an error' do
        transformer.transform
        expect(transformer.errors.full_messages).to eq(["File is not of the right type. Please provide an xlsx, xlsm, or csv file."])
      end
    end

    context 'when file is corrupted' do
      let(:path) { 'spec/fixtures/files/corrupted_simple_manifest.xlsx' }

      it 'returns false' do
        expect(transformer.transform).to be false
      end

      it 'sets an error' do
        transformer.transform
        expect(transformer.errors.full_messages).to eq(["File can not be read. It may be corrupted, or not in the correct format."])
      end
    end

    context 'when any other error is raised' do
      let(:path) { 'spec/fixtures/files/simple_manifest.xlsx' }

      before do
        allow_any_instance_of(Roo::Excelx).to receive(:to_csv).and_raise("kaboom")
      end

      it 'returns false' do
        expect(transformer.transform).to be false
      end

      it 'sets an error' do
        transformer.transform
        expect(transformer.errors.full_messages).to eq(["Something went wrong while reading the file. It may be corrupted, or not in the correct format."])
      end

    end

    context 'when file is an .xlsm' do
      let(:path) { 'spec/fixtures/files/simple_manifest.xlsm' }

      it 'returns true' do
        expect(transformer.transform).to be true
      end

      it 'sets contents' do
        transformer.transform
        expect(transformer.contents).to_not be_nil
      end
    end

    context 'when file is an .xlsx' do
      let(:path) { 'spec/fixtures/files/simple_manifest.xlsx' }

      it 'returns true' do
        expect(transformer.transform).to be true
      end

      it 'sets contents' do
        transformer.transform
        expect(transformer.contents).to_not be_nil
      end
    end

    context 'when file is a .csv' do
      let(:path) { 'spec/fixtures/files/simple_manifest.csv' }

      it 'returns true' do
        expect(transformer.transform).to be true
      end

      it 'sets contents' do
        transformer.transform
        expect(transformer.contents).to_not be_nil
      end
    end

  end

end