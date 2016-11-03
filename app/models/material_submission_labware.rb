class MaterialSubmissionLabware < ApplicationRecord
  belongs_to :material_submission
  belongs_to :labware

  before_create :labware_to_wait_for_reception

  def labware_to_wait_for_reception
    self.state='awaiting receipt'
  end

end
