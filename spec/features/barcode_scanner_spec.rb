require 'rails_helper'
require 'ostruct'
require 'support/wait_for_ajax'

RSpec.feature 'Barcode Scanner', type: :feature do
  describe "when visiting the 'Reception' page" do
    let(:user) { OpenStruct.new(email: 'user@sanger.ac.uk', groups: ['world', 'pirates']) }

    before do
      allow_any_instance_of(JWTCredentials).to receive(:check_credentials)
      allow_any_instance_of(JWTCredentials).to receive(:current_user).and_return(user)

      @material_submission = FactoryBot.create(:material_submission, status: 'printed', dispatched: true, dispatch_date: Time.current)
      @material_submission.labwares = [FactoryBot.create(:labware_with_barcode, material_submission: @material_submission, print_count: 1)]
      visit '/material_receptions'
    end

    context 'scanning a barcode', js: true do
      it 'allows scanning of a correctly formatted barcode with no leading or trailing spaces' do
        find('#material_reception_barcode_value').set("#{@material_submission.labwares[0].barcode}\n").native.send_keys(:return)
        wait_for_ajax
        expect(page).to have_css("td", text: @material_submission.labwares[0].barcode)
      end

      it 'allows scanning of a barcode with leading or trailing spaces' do
        find('#material_reception_barcode_value').set("    #{@material_submission.labwares[0].barcode}    \n").native.send_keys(:return)
        wait_for_ajax
        expect(page).to have_css("td", text: @material_submission.labwares[0].barcode)
      end
    end
  end
end
