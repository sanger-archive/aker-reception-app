require 'pry'
require 'rest-client'

class Biomaterial
  include ActiveModel::Model
  extend BiomaterialClient

  #belongs_to :containable, polymorphic: true, optional: true

  attr_accessor :uuid, :supplier_name, :donor_name, :gender, :common_name, :phenotype
  #validates_presence_of :supplier_name, :donor_name, :gender, :common_name, :phenotype

  #before_create :set_uuid, unless: :uuid?
  #before_create :validate_with_schema


  def save
  	Biomaterial.create({:materials => [JSON.parse(self.to_json)]})
  end

private

  def initialize
  	super()
  	set_uuid
  	#set_uuid if attributes[:uuid].nil?
  	#validate_with_schema
  end

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
