class LabelTemplate < ActiveRecord::Base
  validates_presence_of :name, :external_id
  validates_uniqueness_of :name, :external_id
end
