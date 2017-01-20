class LabelTemplate < ActiveRecord::Base
  validates_presence_of :name, :external_id
  validates_uniqueness_of :name, :external_id

  def self.for_type(type)
    type = {
      'Plate' => ['TubeRack', 'Plate'],
      'Tube' => ['Tube', 'SampleTube']
    }.select{|k,v| v.include?(type)}.first[0]

    where(:template_type => type)
  end
end
