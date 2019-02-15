class Manifest::ProvenanceState::ContentAccessor::ContentMessage
  attr_reader :level, :text, :labware_index, :address, :field

  def initialize(params)
    @level = params[:level]
    @labware_index = params[:labware_index]
    @text = params[:text]
    @address = params[:address]
    @field = params[:field]
  end

  def validate
    true
  end

  def serialize
    {
      level: level,
      text: text,
      labware_index: labware_index,
      address: address,
      field: field
    }
  end
end
