require 'pry'
require 'rest-client'

class Biomaterial
  include ActiveModel::Model
  extend BiomaterialClient

  #belongs_to :containable, polymorphic: true, optional: true

  attr_accessor :uuid, :supplier_name, :donor_name, :gender, :common_name, :phenotype, :donor_id

  def attributes
    [:supplier_name, :donor_name, :gender, :common_name, :phenotype].map do |k|
      if k == :donor_name
        [:donor_id, send(k)]
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

  def self.find(biomaterial_id)

    new(get(biomaterial_id).keep_if{|k,v| attrs_list.keys.include?(k)})
  end

  #validates_presence_of :supplier_name, :donor_name, :gender, :common_name, :phenotype

  #before_create :set_uuid, unless: :uuid?
  #before_create :validate_with_schema

  def save(biomaterial_id = nil)
    if biomaterial_id
      response = self.class.put(biomaterial_id, attributes)
    else
      response = self.class.post(attributes)
    end
    self.uuid = response["_id"]
  end

private

  def set_uuid
    self.uuid = UUID.new.generate
  end

  def schema
  	{:schema => JSON.parse(Schema.get.to_s)}
  end

  def validate_with_schema
  	JSON::Validator.validate!(Schema.get, attributes)
  end
end
