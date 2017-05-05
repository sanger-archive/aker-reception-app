require 'rails_helper'

RSpec.describe :provenance_service do

  setup do
    @schema = {
      'required' => ['REQUIRED_FREE', 'REQUIRED_ENUM'],
      'properties' => {
        'OPTIONAL' => {
          'required' => false,
        },
        'REQUIRED_FREE' => {
          'required' => true,
        },
        'REQUIRED_ENUM' => {
          'required' => true,
          'enum' => ['ALPHA', 'BETA', 'GAMMA'],
        }
      },
    }
    @service = ProvenanceService.new(@schema)
  end

  describe "#validate" do

    let(:properties) do
      {
        'REQUIRED_FREE' => 'xyz',
        'REQUIRED_ENUM' => 'Alpha',
      }
    end

    let(:labware_index) { 10 }

    context "when missing required fields" do
      before do
        data = {
          "1" => properties,
          "2" => {
            'OPTIONAL' => "bananas",
          },
          "3" => properties,
        }
        @results = @service.validate(labware_index, data)
      end

      it "should produce appropriate errors" do
        expect(@results.length).to eq 1
        result = @results.first
        expect(result[:labwareIndex]).to eq labware_index
        expect(result[:address]).to eq "2"
        errors = result[:errors]
        expect(errors.length).to eq 2
        expect(errors[:REQUIRED_FREE]).not_to be_nil
        expect(errors[:REQUIRED_ENUM]).not_to be_nil
      end
    end

    context "when enum field has wrong value" do
      before do
        data = {
          "1" => properties,
          "2" => {
            'REQUIRED_FREE' => "xyz",
            'REQUIRED_ENUM' => "bananas",
          },
          "3" => properties,
        }
        @results = @service.validate(labware_index, data)
      end

      it "should produce appropriate errors" do
        expect(@results.length).to eq 1
        result = @results.first
        expect(result[:labwareIndex]).to eq labware_index
        expect(result[:address]).to eq "2"
        errors = result[:errors]
        expect(errors.length).to eq 1
        expect(errors[:REQUIRED_ENUM]).to include('"ALPHA", "BETA", "GAMMA"')
      end
    end

    context "when data contains wrong capitalisation" do
      before do
        @data = {
          "1" => properties,
          "2" => {
            'REQUIRED_FREE' => "xyz",
            'REQUIRED_ENUM' => "Alpha",
          },
          "3" => properties,
        }
        @results = @service.validate(labware_index, @data)
      end

      it "should accept the data" do
        expect(@results).to be_empty
      end

      it "should correct the capitalisation" do
        expect(@data["2"]['REQUIRED_ENUM']).to eq "ALPHA"
      end
    end

    context "when data extra fields" do
      before do
        @data = {
          "1" => {
            'REQUIRED_FREE' => "xyz",
            'REQUIRED_ENUM' => "ALPHA",
            'some_extra_field' => "bananas",
          },
        }
        @results = @service.validate(labware_index, @data)
      end

      it "should accept the data" do
        expect(@results).to be_empty
      end
    end
  end

  describe "#set_biomaterial_data" do
    def make_submission(labwares)
      submission = double(:material_submission, labwares: labwares)
    end

    def make_labwares(number)
      (1..number).map do |i|
        lw = double(:labware, labware_index: i, positions: ['1','2'])
        allow(lw).to receive(:update_attributes).and_return(true)
        lw
      end
    end

    let(:good_labware_data_long) do
      {
        "1" => {
          'REQUIRED_FREE' => 'xyz',
          'REQUIRED_ENUM' => 'alpha',
        },
        "2" => {
          'REQUIRED_FREE' => 'xyz',
          'REQUIRED_ENUM' => 'BETA',
          'OPTIONAL' => 'bananas',
        }
      }
    end

    let(:good_labware_data_short) do
      {
        "1" => {
          'REQUIRED_FREE' => 'xyz',
          'REQUIRED_ENUM' => 'Beta',
          'OPTIONAL' => '',
        },
        "2" => {}
      }
    end

    let(:missing_field_labware_data) do
      {
        "1" => {
          'REQUIRED_ENUM' => 'beta',
        }
      }
    end

    let(:enum_field_wrong_labware_data) do
      {
        "1" => {
          'REQUIRED_FREE' => 'xyz',
          'REQUIRED_ENUM' => 'Alabama',
        }
      }
    end

    context "when nothing goes wrong" do
      before do
        @labwares = make_labwares(2)
        @submission = make_submission(@labwares)
        @data = { "1" => good_labware_data_long, "2" => good_labware_data_short }
        @success, @errors = @service.set_biomaterial_data(@submission, @data)
      end

      it "should succeed" do
        expect(@success).to eq true
      end

      it "should have no errors" do
        expect(@errors).to be_empty
      end

      it "should have updated the labware with filtered contents" do
        expect(@labwares[0]).to have_received(:update_attributes).with(contents: {
          "1" => {
            'REQUIRED_FREE' => 'xyz',
            'REQUIRED_ENUM' => 'ALPHA',
          },
          "2" => {
            'REQUIRED_FREE' => 'xyz',
            'REQUIRED_ENUM' => 'BETA',
            'OPTIONAL' => 'bananas',
          },
        })
        expect(@labwares[1]).to have_received(:update_attributes).with(contents: {
          "1" => {
            'REQUIRED_FREE' => 'xyz',
            'REQUIRED_ENUM' => 'BETA',
          },
        })
      end
    end

    context "when validation fails" do
      before do
        @labwares = make_labwares(2)
        @submission = make_submission(@labwares)
        @data = { "1" => missing_field_labware_data, "2" => enum_field_wrong_labware_data }
        @success, @errors = @service.set_biomaterial_data(@submission, @data)
      end

      it "should not succeed" do
        expect(@success).to eq false
      end

      it "should return the errors" do
        expect(@errors.length).to eq 2
      end

      it "should nevertheless have updated the labware with filtered contents" do
        expect(@labwares[0]).to have_received(:update_attributes).with(contents: {
          "1" => {
            'REQUIRED_ENUM' => 'BETA',
          },
        })
        expect(@labwares[1]).to have_received(:update_attributes).with(contents: {
          "1" => {
            'REQUIRED_FREE' => 'xyz',
            'REQUIRED_ENUM' => 'Alabama',
          },
        })
      end
    end

    context "when some labware data is missing from params" do
      before do
        @labwares = make_labwares(2)
        @submission = make_submission(@labwares)
        @data = { "1" => good_labware_data_short }
        @success, @errors = @service.set_biomaterial_data(@submission, @data)
      end

      it "should not succeed" do
        expect(@success).to eq false
      end

      it "should return the error" do
        expect(@errors.length).to eq 1
        error = @errors.first
        expect(error[:labwareIndex]).to eq 2
        expect(error[:errors].length).to eq 1
        expect(error[:errors].values.first).to eq "At least one material must be specified for each item of labware"
      end

      it "should nevertheless have updated the labware with filtered contents" do
        expect(@labwares[0]).to have_received(:update_attributes).with(contents: {
          "1" => {
            'REQUIRED_FREE' => 'xyz',
            'REQUIRED_ENUM' => 'BETA',
          },
        })
        expect(@labwares[1]).to have_received(:update_attributes).with(contents: nil)
      end
    end

    context "when some labware data is empty in params" do
      before do
        @labwares = make_labwares(2)
        @submission = make_submission(@labwares)
        @data = { "1" => good_labware_data_short, "2" => { "1" => { 'REQUIRED_FREE' => '' } }}
        @success, @errors = @service.set_biomaterial_data(@submission, @data)
      end

      it "should not succeed" do
        expect(@success).to eq false
      end

      it "should return the error" do
        expect(@errors.length).to eq 1
        error = @errors.first
        expect(error[:labwareIndex]).to eq 2
        expect(error[:errors].length).to eq 1
        expect(error[:errors].values.first).to eq "At least one material must be specified for each item of labware"
      end

      it "should nevertheless have updated the labware with filtered contents" do
        expect(@labwares[0]).to have_received(:update_attributes).with(contents: {
          "1" => {
            'REQUIRED_FREE' => 'xyz',
            'REQUIRED_ENUM' => 'BETA',
          },
        })
        expect(@labwares[1]).to have_received(:update_attributes).with(contents: nil)
      end
    end
  end
end
