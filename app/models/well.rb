class Well
  include ActiveModel::Model
  include ActiveModel::Conversion

  #include ActiveModel::Validations
  attr_accessor :address, :material

  alias_attribute :position, :address
  alias_attribute :id, :address
  #belongs_to :labware
  #has_one :biomaterial, as: :containable, dependent: :nullify

  #default_scope { order(:id => :asc)}

  #validates :position, presence: true, uniqueness: { scope: :labware_id }

  validate :biomaterial_json_schema_is_valid
 
  def biomaterial_json_schema_is_valid
    if biomaterial
      unless biomaterial.valid?
        errors.add(:base, biomaterial.errors)
        return false
      end
    end
    true
  end

  attr_writer :biomaterial

  def attributes
    list_attrs = [:address]
    list_attrs.push(:material) if material
    list_attrs.map do |k|
      [k, send(k)]
    end.to_h
  end



  def biomaterial_id
    material
  end

  def biomaterial_id=(id)
    
  end

  def biomaterial
  	@biomaterial ||= Biomaterial.find(biomaterial_id)
  end

  def biomaterials
    [biomaterial].compact
  end

  #attr_accessor :biomaterial_id
  #accepts_nested_attributes_for :biomaterial, reject_if: :all_attributes_blank?

  def convert_attributes(attrs)
    attrs[:donor_id] = attrs[:donor_name]
    attrs.delete(:donor_name)
    attrs
  end

  def biomaterial_attributes=(attrs)
    attrs = convert_attributes(attrs)
    if biomaterial_id
      biomaterial = Biomaterial.find(biomaterial_id)
      biomaterial.assign_attributes(attrs)
    else
      biomaterial = Biomaterial.new(attrs)
    end
    unless biomaterial.is_empty?
      biomaterial.save!(biomaterial_id)
      assign_attributes(:material => biomaterial.uuid)
    end
  end


  def all_attributes_blank?(attributes)
    [:supplier_name, :donor_name, :gender, :common_name, :phenotype].all? do |attribute| 
      attributes[attribute].blank? 
    end
  end
end
