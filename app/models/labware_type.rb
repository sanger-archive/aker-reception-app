class LabwareType < ApplicationRecord

  validates :name, presence: true
  validates :num_of_cols, presence: true, numericality: { integer: true, greater_than: 0 }
  validates :num_of_rows, presence: true, numericality: { integer: true, greater_than: 0 }
  validates :col_is_alpha, inclusion: { in: [true, false] }
  validates :row_is_alpha, inclusion: { in: [true, false] }

  before_validation :sanitise_name
  before_save :sanitise_name

  def size
    num_of_cols * num_of_rows
  end

  def sanitise_name
    if name
      sanitised = name.strip.gsub(/\s+/, ' ')
      if sanitised != name
        self.name = sanitised
      end
    end
  end

end
