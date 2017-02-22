require 'material_service_client'


class Labware
  include ActiveModel::Model
  include ActiveModel::Conversion

  attr_accessor :num_of_cols, :barcode, :_updated, :num_of_rows, :_id, :row_is_alpha, :col_is_alpha, :slots
  attr_accessor :_status, :_issues
  attr_accessor :_links, :_created

  alias_attribute :uuid, :_id
  alias_attribute :id, :_id


  attr_writer :wells 

  #alias_attribute :wells, :slots

  #include Barcodeable

  #belongs_to :labware_type

  def attributes
    [:num_of_cols, :barcode, :_updated, :num_of_rows, :uuid, :row_is_alpha, :col_is_alpha, :slots,
      :_status, :_issues,
      :_links, :_created
    ].map do |k|      
      [k, send(k)]
    end.to_h
  end

  def wells
    @wells ||= slots.map do |s|
      Well.new(s)
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
      end
    end

    attrs["wells_attributes"].values.each do |attr_well|
      well = wells.select{|w| w.address == attr_well["position"]}.first
      well.biomaterial_attributes=attr_well["biomaterial_attributes"]
    end
    
    assign_attributes(attrs)
    self.save!
  end

  def wells_attributes=(params)
  end

  #has_one :material_reception
  def material_reception
  end

  def material_submission_labware
  end

  def material_submission
    #, through: :material_submission_labware
  end
  #def wells
    #, dependent: :destroy
  #end

  #accepts_nested_attributes_for :wells

  #before_create :build_default_wells
  
  delegate :size, :x_dimension_is_alpha, :y_dimension_is_alpha, :x_dimension_size, :y_dimension_size, to: :labware_type

  def self.with_barcode(barcode)
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

  def barcode_printed?
    barcode.print_count > 0
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
    if (!x_dimension_is_alpha && !y_dimension_is_alpha)
      return (1..size).to_a
    end

    if x_dimension_is_alpha
      x = ("A"..("A".ord + x_dimension_size - 1).chr).to_a
    else
      x = (1..x_dimension_size).to_a
    end

    if y_dimension_is_alpha
      y = ("A"..("A".ord + y_dimension_size - 1).chr).to_a
    else
      y = (1..y_dimension_size).to_a
    end

    y.product(x).map(&:join)
  end

  def attributes_to_send
    attributes.map.reject{|k,v| ["_updated", "barcode", "_issues", "_links", "_created", "_status"].include?(k.to_s)}.to_h
  end

  def save
    assign_attributes(MaterialServiceClient::Container.put(attributes_to_send))
    debugger
    valid?
  end

  def save!
    raise ActiveRecord::RecordInvalid unless valid?
    save
  end


private

  def build_default_wells
    wells.build(positions.map { |position| { position: position } })
    true
  end


end
