require 'rails_helper'
require 'ostruct'

RSpec.feature "DualPrintForms", type: :feature do

  describe "printer selection", js: true do
    let(:user) { OpenStruct.new(email: 'user@sanger.ac.uk', groups: %w[world team252]) }
    let(:printer_names) { ['Printer 1', 'Printer 2']}
    let(:contact) { create(:contact) }
    let!(:matsub) do
      create(:material_submission, #no_of_labwares_required: 1,
        supply_labwares: false, owner_email: user.email, address: "1 street", set_id: "03ae0fde-5657-4eda-ab34-178894d41f86",
        status: 'active', contact_id: contact.id)
    end
    let!(:printers) { printer_names.map { |name| create(:printer, name: name, label_type: "Tube") } }
    let(:printer_options) { printers.map { |printer| "#{printer.name} (#{printer.label_type})"} }

    before do
      allow_any_instance_of(JWTCredentials).to receive(:check_credentials)
      allow_any_instance_of(JWTCredentials).to receive(:current_user).and_return(user)
      visit completed_submissions_path
    end

    context "when the page is loaded" do
      it "shows both dropdown menus with all available printers" do
        expect(page).to have_select("printer_name_top", options: printer_options)
        expect(page).to have_select("printer_name_bottom", options: printer_options)
      end

      it "shows both the top and bottom print buttons" do
        expect(page).to have_button("print_button_top")
        expect(page).to have_button("print_button_bottom")
      end
    end
  end
end
