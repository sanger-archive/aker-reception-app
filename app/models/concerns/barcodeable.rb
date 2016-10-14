module Barcodeable
  extend ActiveSupport::Concern

  included do
    has_one :barcode, as: :barcodeable, foreign_key: :barcodeable_id

    after_create :set_barcode

    private

    def set_barcode
      self.create_barcode(value: "AKER_#{id}", barcode_type: 'CODE_128')
    end
  end

end
