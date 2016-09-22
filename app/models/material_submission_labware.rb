class MaterialSubmissionLabware < ApplicationRecord
  belongs_to :material_submission
  belongs_to :labware
end
