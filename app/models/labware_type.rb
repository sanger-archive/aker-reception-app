class LabwareType < ApplicationRecord

  validates :name, presence: true
  validates :num_of_cols, presence: true, numericality: { integer: true, greater_than: 0 }
  validates :num_of_rows, presence: true, numericality: { integer: true, greater_than: 0 }
  validates :col_is_alpha, inclusion: { in: [true, false] }
  validates :row_is_alpha, inclusion: { in: [true, false] }

  def self.create_labwares(params)
    find(params.fetch(:labware_type_id)).create_labwares(params.fetch(:number, 1))
  end

  def labware_args
    attributes.reject{|k,v| !["num_of_cols","num_of_rows","col_is_alpha","row_is_alpha"].include?(k)}    
  end

  def create_labwares(number = 1)
    labwares_args = Array.new(number, labware_args)

    MaterialSubmissionLabware.new_list(labwares_args)
  end

  def create_labware
    create_labwares(1).first
  end

  def size
    num_of_cols * num_of_rows
  end

end
