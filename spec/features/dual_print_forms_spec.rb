require 'rails_helper'
require 'ostruct'

RSpec.feature "DualPrintForms", type: :feature do

  describe "printer selection", js: true do
    before :each do
      @user = OpenStruct.new(:email => 'user@sanger.ac.uk', :groups => ['world'])
      allow_any_instance_of(JWTCredentials).to receive(:current_user).and_return(@user)

      @printer1 = create(:printer, name: "Printer 1")
      @printer2 = create(:printer, name: "Printer 2")

      @contact = create(:contact)
      @matsub = create(:material_submission, #no_of_labwares_required: 1,
      supply_labwares: false, owner_email: @user.email, address: "1 street", set_id: "03ae0fde-5657-4eda-ab34-178894d41f86",
      status: 'active', contact_id: @contact.id)

      visit completed_submissions_path
    end

    context "when the page is loaded" do
      it "shows both dropdown menus with all available printers" do
        expect(page).to have_select("printer_name_top", options: [@printer1.name, @printer2.name])
        expect(page).to have_select("printer_name_bottom", options: [@printer1.name, @printer2.name])
      end

      it "shows both the top and bottom print buttons" do
        expect(page).to have_button("print_button_top")
        expect(page).to have_button("print_button_bottom")
      end
    end

    context "when choosing from the top dropdown" do
      it "mirrors the option to the bottom dropdown" do
        expect(page).to have_select("printer_name_top", selected: @printer1.name)
        select @printer2.name, from: "printer_name_top"
        wait_for_ajax
        expect(page).to have_select("printer_name_bottom", selected: @printer2.name)
      end
    end

    context "when choosing from the bottom dropdown" do
      it "mirrors the option to the top dropdown" do
        expect(page).to have_select("printer_name_bottom", selected: @printer1.name)
        select @printer2.name, from: "printer_name_bottom"
        wait_for_ajax
        expect(page).to have_select("printer_name_top", selected: @printer2.name)
      end
    end

    context "when clicking the top print button" do
      it "prints to the selected printer" do
        check('completed_submission_ids_')
        select @printer2.name, from: "printer_name_bottom"
        wait_for_ajax
        click_button("print_button_top")
        expect(page).to have_content("Print issued to #{@printer2.name}")
      end
    end

    context "when clicking the bottom print button" do
      it "prints to the selected printer" do
        check('completed_submission_ids_')
        select @printer2.name, from: "printer_name_top"
        wait_for_ajax
        click_button("print_button_bottom")
        expect(page).to have_content("Print issued to #{@printer2.name}")
      end
    end

  end
end
