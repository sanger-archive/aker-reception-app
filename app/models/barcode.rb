class Barcode < ApplicationRecord
  belongs_to :barcodeable, polymorphic: true
end
