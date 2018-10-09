require 'rails_helper'

RSpec.shared_examples "failed transformation" do |params|
  it 'returns false' do
    expect(transformer.transform).to be false
  end

  it 'sets an error' do
    transformer.transform
    expect(transformer.errors.full_messages).to eq(params[:errors])
  end
end

RSpec.shared_examples "successful transformation" do
  it 'returns true' do
    expect(transformer.transform).to be true
  end

  it 'sets contents' do
    transformer.transform
    expect(transformer.contents).to eq([
      { well_position: 'A:1', tumour: 'Normal', gender: 'male', hmdmc: nil, donor_id: '3', phenotype: '6', supplier_name: '78placebo-501', taxon_id: '9606', tissue_type: 'RNA' },
      { well_position: 'B:1', tumour: 'Normal', gender: 'male', hmdmc: nil, donor_id: '3', phenotype: '6', supplier_name: '78placebo-502', taxon_id: '9606', tissue_type: 'RNA' },
      { well_position: 'C:1', tumour: 'Normal', gender: 'female', hmdmc: nil, donor_id: '3', phenotype: '6', supplier_name: '78placebo-503', taxon_id: '9606', tissue_type: 'RNA' }
    ])
  end
end

RSpec.describe Transformers::ExcelToArray do

  let(:transformer) { Transformers::ExcelToArray.new(path: path) }

  describe '#initialization' do

    context 'when path is not provided' do
      it 'raises an error' do
        expect { Transformers::ExcelToArray.new(plath: 'ooops') }.to raise_error(KeyError)
      end
    end

  end

  describe '#transform' do

    context 'when file can not be found' do
      let(:path) { '/fake/path/to/spreadsheet.xlsx' }
      include_examples "failed transformation", errors: ["File could not be found."]
    end

    context 'when file is the wrong format' do
      let(:path) { 'spec/fixtures/files/WorkOrderJobSets.png' }
      include_examples "failed transformation", errors: ["File is not of the right type. Please provide an xlsx, xlsm, or csv file."]
    end

    context 'when file is corrupted' do
      let(:path) { 'spec/fixtures/files/corrupted_simple_manifest.xlsx' }
      include_examples "failed transformation", errors: ["File can not be read. It may be corrupted, or not in the correct format."]
    end

    context 'when any other error is raised' do
      let(:path) { 'spec/fixtures/files/simple_manifest.xlsx' }

      before do
        allow_any_instance_of(Roo::Excelx).to receive(:to_csv).and_raise("kaboom")
      end

      include_examples "failed transformation", errors: ["Something went wrong while reading the file. It may be corrupted, or not in the correct format."]
    end

    context 'when file is an .xlsm' do
      let(:path) { 'spec/fixtures/files/simple_manifest.xlsm' }
      include_examples "successful transformation"
    end

    context 'when file is an .xlsx' do
      let(:path) { 'spec/fixtures/files/simple_manifest.xlsx' }
      include_examples "successful transformation"
    end

    context 'when file is a .csv' do
      let(:path) { 'spec/fixtures/files/simple_manifest.csv' }
      include_examples "successful transformation"
    end

    context 'when file has blank lines' do
      let(:path) { 'spec/fixtures/files/simple_manifest.csv' }
      include_examples "successful transformation"
    end

  end

end