require 'rails_helper'

def step_params(material_submission, step_name)
  {:params => {
    :material_submission => case step_name
      when :labware
        {
              :supply_labwares => true,
              :no_of_labwares_required => 1,
              :status => 'labware',
              :labware_type_id => @labware_type.id
        }
      when :provenance
        {
              :status => 'provenance',
              :labwares_attributes => plate_attributes_for(material_submission.labwares)
        }
      when :dispatch
        {
          :status => 'active',
          :address => 'Testing address',
          :contact_attributes => { :email => 'Contact test email'}
        }
      when :dispatch_contact_error
        step_name = :dispatch
        {
          :status => 'active',
          :contact_attributes => {:email => ''},
          :address => 'Testing address',
        }
      end
    }.merge(
      {
        :material_submission_id => material_submission.id,
        :id => step_name
      }
    )
  }
end


def wells_attributes_for(plate)
  plate.wells.each_with_index.reduce({}) do |memo, list|
    well,index = list[0],list[1]
    memo[index.to_s] = {
      :id => well.id.to_s,
      :position => well.position,
      :biomaterial_attributes => {
        #{}"0" => {
          :supplier_name => 'Test',
          :donor_name => 'Test',
          :gender => 'Test',
          :common_name => 'Test',
          :phenotype => 'Test'
        #}
      }
    }
    memo
  end
end

def plate_attributes_for(labwares)
  labwares.each_with_index.reduce({}) do |mlabware, list|
    plate, plate_idx = list[0],list[1]
    mlabware[plate_idx.to_s] = {
      :id => plate.id.to_s,
      :wells_attributes => wells_attributes_for(plate)
    }
    mlabware
  end

end


RSpec.describe SubmissionsController, type: :controller do
  describe "Using the steps defined by wicked" do
    setup do
      @labware_type = FactoryGirl.create :labware_type
      @material_submission = FactoryGirl.create :material_submission
    end

    it "does not update the submission state if any steps have not been performed" do
      put :update, step_params(@material_submission, :dispatch)
      @material_submission.reload
      expect(@material_submission.status).not_to eq('active')
    end

    it "does not update the submission state if any required data of steps has not been provided" do
      put :update, step_params(@material_submission, :labware)
      @material_submission.reload
      put :update, step_params(@material_submission, :provenance)
      @material_submission.reload
      put :update, step_params(@material_submission, :dispatch_contact_error)
      @material_submission.reload
      expect(@material_submission.status).not_to eq('active')
    end


    it "updates the submission state to active when all the required data of the steps has been provided" do
      put :update, step_params(@material_submission, :labware)
      @material_submission.reload
      put :update, step_params(@material_submission, :provenance)
      @material_submission.reload
      put :update, step_params(@material_submission, :dispatch)
      @material_submission.reload
      expect(@material_submission.status).to eq('active')
    end
  end
end
