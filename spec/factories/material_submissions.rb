FactoryGirl.define do
  factory :material_submission do
    labware_type {|lt| lt.association(:labware_type, num_of_cols: 1, num_of_rows: 1,
      row_is_alpha: true, col_is_alpha: true)}
    owner_email 'owner@sanger.ac.uk'
    contact

  end
end
