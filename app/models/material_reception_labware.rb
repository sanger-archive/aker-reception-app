class MaterialReceptionLabware < ApplicationRecord
  belongs_to :material_reception
  belongs_to :labware
end
