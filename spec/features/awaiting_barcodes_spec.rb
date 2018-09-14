require 'rails_helper'
require 'ostruct'

RSpec.feature 'AwaitingBarcodes', type: :feature do
  describe "when visiting the 'Manifests Awaiting Receipt' page" do
    let(:user) { OpenStruct.new(email: 'user@sanger.ac.uk', groups: ['world, pirates']) }

    before do
      allow_any_instance_of(JWTCredentials).to receive(:check_credentials)
      allow_any_instance_of(JWTCredentials).to receive(:current_user).and_return(user)

      @material_submission = FactoryBot.create(:dispatched_material_submission)
      @labwares = []
      3.times { @labwares << FactoryBot.create(:barcoded_labware, material_submission: @material_submission, print_count: 1) }
      @material_submission.labwares << @labwares
    end

    context 'with a submission with NO barcodes received' do
      it 'shows the submission and relevant (all) barcodes' do
        visit '/material_receptions/waiting'
        @labwares.each do |lw|
          expect(page).to have_text(lw.barcode)
        end
      end

      it "doesn't show non-dispatched barcodes" do
        # Create a submission (and labware) that hasn't been printed or dispatched
        @material_submission_not_dispatched = FactoryBot.create(:active_material_submission)
        @labwares_not_dispatched = []
        2.times { @labwares_not_dispatched << FactoryBot.create(:barcoded_labware, material_submission: @material_submission_not_dispatched, print_count: 0) }
        @material_submission_not_dispatched.labwares << @labwares_not_dispatched

        visit '/material_receptions/waiting'

        # Ensure none of the barcodes for this submission don't appear on the page
        @labwares_not_dispatched.each do |lw|
          expect(page).to_not have_text(lw.barcode)
        end
      end
    end

    context 'with a submission with SOME barcodes received' do
      it 'shows the submission and relevant (some) barcodes' do
        # Dispatch the barcode for the specified piece of labware
        index_to_dispatch = 1
        FactoryBot.create(:material_reception, labware_id: @labwares[index_to_dispatch].id)

        visit '/material_receptions/waiting'

        # Ensure all barcodes except the one dispatched above are visible
        @labwares.each_with_index do |lw, i|
          if i != index_to_dispatch
            expect(page).to have_text(lw.barcode)
          else
            expect(page).to_not have_text(lw.barcode)
          end
        end
      end
    end

    context 'with a submission with ALL barcodes received' do
      it 'shows the submission and relevant (none) barcodes' do
        # Dispatch the barcode for each piece of labware
        @labwares.each do |lw|
          FactoryBot.create(:material_reception, labware_id: lw.id)
        end

        visit '/material_receptions/waiting'

        @labwares.each do |lw|
          expect(page).to_not have_text(lw.barcode)
        end
      end
    end
  end
end
