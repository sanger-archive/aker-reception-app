class Tube < Labware
  has_one :biomaterial, as: :containable
end
