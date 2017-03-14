require 'material_service_client'


class Labware
  include ActiveModel::Model
  include ActiveModel::Conversion

  attr_accessor :num_of_cols, :barcode, :_updated, :num_of_rows, :_id, :row_is_alpha, :col_is_alpha, :slots
  attr_accessor :_status, :_issues
  attr_accessor :_links, :_created
  attr_accessor :_error
  attr_accessor :print_count
  attr_accessor :labware_type

  alias_attribute :uuid, :_id
  alias_attribute :id, :_id


  validate :wells_are_valid?

  def wells_are_valid?
    wells.each do |w|
      if w.invalid?
        errors.add(w.address, w.errors)
      end
    end
    return false unless errors.empty?
  end

  attr_writer :wells 


  def attributes
    [:num_of_cols, :print_count, :barcode, :_updated, :num_of_rows, :uuid, :row_is_alpha, :col_is_alpha, :slots,
      :_status, :_issues,
      :_links, :_created
    ].map do |k|
      if k==:slots
        [k, wells ? wells.map(&:attributes) : []]
      else
        [k, send(k)]
      end
    end.to_h
  end

  def wells
    return nil unless slots || @wells
    @wells ||= slots.map do |s|
      Well.new(s.merge(:labware => self))
    end
  end

  def well_at_position(position)
    wells.select{|w| w.position==position}.first
  end

  def self.find(uuid)
    new(MaterialServiceClient::Container.get(uuid))
  end

  def form_attrs_to_service_attrs(attrs)
  end

  def update(attrs)
    attrs["wells_attributes"].values.select {|well| well["biomaterial_attributes"].values.all?{|b| b.empty?}}.each do |well|
      well = well_at_position(well["position"])
      biomaterial_id =  well.biomaterial_id
      unless biomaterial_id.nil?
        well.biomaterial.destroy
        well.biomaterial = nil
      end
    end

    attrs["wells_attributes"].values.each do |attr_well|
      well = wells.select{|w| w.address == attr_well["position"]}.first
      well.biomaterial_attributes=attr_well["biomaterial_attributes"]
    end
    
    #assign_attributes(attrs)
    self.save
  end

  def wells_attributes=(params)
  end

  #has_one :material_reception
  def material_reception
    MaterialReception.where(:labware_id => uuid).first
  end

  def material_submission
    material_submission_labware.material_submission
  end

  def material_submission_labware
    MaterialSubmissionLabware.where(:labware_id => uuid).first
  end
  #def wells
    #, dependent: :destroy
  #end

  #accepts_nested_attributes_for :wells

  #before_create :build_default_wells
  
  #delegate :size, :col_is_alpha, :row_is_alpha, :num_of_cols, :num_of_rows, to: :labware_type

  def size
    num_of_rows * num_of_cols
  end

  def self.with_barcode(barcode)
    instances = MaterialServiceClient::Container.with_criteria({:where=>{:barcode => barcode}})["_items"]
    instances.map{|instance| new(instance)}
  end
  #scope :with_barcode, ->(barcode) {
  #  joins(:barcode).where(:barcodes => {:value => barcode })
  #}


  def biomaterials
    wells.map(&:biomaterial)
  end

  def waiting_receipt
    material_submission_labware.update_attributes(:state => 'awaiting receipt')
  end

  def received_unclaimed
    material_submission_labware.update_attributes(:state => 'received unclaimed') if barcode_printed?
  end

  def print_count
    @print_count || 0
  end


  def increment_print_count!
    @print_count=self.print_count+1
    save!
  end

  def barcode_printed?
    print_count && print_count > 0
  end

  def received_unclaimed?
    material_submission_labware.state == 'received unclaimed'
  end

  def invalid_data
    if invalid?
      wells.map{|w| w if w.invalid?}.compact.map do |invalid_well|
        {
          :labware_id => self.id,
          :well_id => invalid_well.id,
          :errors => invalid_well.errors.messages
        }
      end.flatten.compact
    end
  end

  def positions
    if (!col_is_alpha && !row_is_alpha)
      return (1..size).to_a
    end

    if col_is_alpha
      x = ("A"..("A".ord + num_of_cols - 1).chr).to_a
    else
      x = (1..num_of_cols).to_a
    end

    if row_is_alpha
      y = ("A"..("A".ord + num_of_rows - 1).chr).to_a
    else
      y = (1..num_of_rows).to_a
    end

    y.product(x).map(&:join)
  end

  def attributes_to_send
    attributes.map.reject{|k,v| ["_updated", "_issues", "_links", "_created", "_status"].include?(k.to_s)}.to_h
  end

  def save
    assign_attributes(MaterialServiceClient::Container.put(attributes_to_send))
    valid?
  end

  def save!
    save 
    raise ActiveRecord::RecordInvalid unless valid?
  end


private

  def build_default_wells
    wells.build(positions.map { |position| { position: position } })
    true
  end


end
