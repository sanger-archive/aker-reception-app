require 'pry'

class Biomaterial
  include ActiveModel::Model
  include ActiveModel::Conversion

  validate :validate_with_schema

  def persisted?
    false
  end
 
  def id
    nil
  end

  extend BiomaterialClient

  #belongs_to :containable, polymorphic: true, optional: true

  attr_accessor :uuid, :supplier_name, :donor_name, :gender, :common_name, :phenotype, :donor_id

  def attributes
    [:supplier_name, :donor_name, :gender, :common_name, :phenotype].map do |k|
      if (k == :donor_name)
        if (send(:donor_id).nil?)
          [:donor_id, send(k)]
        else
          [:donor_id, send(:donor_id)]
        end
      else
        [k, send(k)]
      end
    end.to_h
  end


  def is_empty?
    attributes.values.all?{|k| k.nil? || k.empty?}
  end

  def self.attrs_list
    [:uuid, :supplier_name, :donor_name, :gender, :common_name, :phenotype, :donor_id]
  end

  def self.filter_attrs(obj)
    obj.keep_if{|k,v| attrs_list.include?(k.to_sym)}
  end

  def self.find(biomaterial_id)
    obj = get(biomaterial_id)
    return nil if obj.nil?
    obj['uuid'] = obj['_id']
    new(filter_attrs(obj))
  end

  #validates_presence_of :supplier_name, :donor_name, :gender, :common_name, :phenotype

  #before_create :set_uuid, unless: :uuid?
  #before_create :validate_with_schema

  def save(biomaterial_id = nil)
    if biomaterial_id
      attributes_with_id = attributes
      attributes_with_id[:uuid] = biomaterial_id
      response = self.class.put(self.class.filter_attrs(attributes_with_id))
    else
      self.class.filter_attrs(attributes)
      response = self.class.post(self.class.filter_attrs(attributes))
    end
    self.uuid = response["_id"]
    valid?
  end

  def save!(biomaterial_id = nil)
    raise ActiveRecord::RecordInvalid unless valid?
    save(biomaterial_id)
  end

private

  def set_uuid
    self.uuid = UUID.new.generate
  end

  def validate_with_schema
    error_msgs = JSON::Validator.fully_validate(Schema.get, attributes)
    if error_msgs.length > 0
      error_msgs.each do |msg|
        errors.add(:schema, :message => msg)
      end
      return false
    end
    true
  end
end
