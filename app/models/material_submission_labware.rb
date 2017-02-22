class MaterialSubmissionLabware < ApplicationRecord
  attr_accessor :labware
  belongs_to :material_submission

  before_create :labware_to_wait_for_reception

  def labware_to_wait_for_reception
    self.state='awaiting receipt'
  end

  def self.new_list(params_list)
    params_list.map do |params|
      new({:labware_id =>MaterialServiceClient::Container.post(params)['_id'] })
    end
  end

  def labware
    @labware ||= Labware.new(MaterialServiceClient::Container.get(labware_id))
  end

  def labware_attributes=(attrs)
    @labware.update_attributes(attrs)
  end

end
