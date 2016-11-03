class Tube < Labware
  belongs_to :labware_type
  has_one :biomaterial, as: :containable
end
