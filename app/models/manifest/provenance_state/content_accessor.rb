require 'active_support/core_ext/module/delegation'

class Manifest::ProvenanceState::ContentAccessor < Manifest::ProvenanceState::Accessor
  delegate :manifest_schema_field, to: :provenance_state
  delegate :manifest_schema_field_required?, to: :provenance_state
  delegate :manifest_model, to: :provenance_state

  def rebuild?
    (super || !present_structured? || (present_raw? && @state[:mapping][:rebuild]))
  end

  def present_mapping?
    (@state[:mapping] && @state[:mapping][:shown])
  end

  def present_raw?
    (state_access.key?(:raw) && !state_access[:raw].nil?)
  end

  def present_structured?
    (state_access.key?(:structured) && !state_access[:structured].nil?)
  end

  class PositionNotFound < StandardError ; end
  class LabwareNotFound < StandardError ; end
  class PositionDuplicated < StandardError ; end
  class WrongNumberLabwares < StandardError ; end


  def present?
    super && present_structured?
  end

  def build
    {
      raw: state_access && state_access[:raw],
      structured: (state_access && state_access[:raw] && @state[:mapping]) ? read_from_raw : read_from_database
    }
  end

  def validate
    if state_access[:structured][:labwares]
      num_labwares_file = state_access[:structured][:labwares].keys.length
      num_labwares_manifest = manifest_model.labwares.count
      if (num_labwares_file > num_labwares_manifest)
        raise WrongNumberLabwares.new("Expected #{num_labwares_manifest} labwares in Manifest but found #{num_labwares_file}.")
      elsif (num_labwares_file < num_labwares_manifest)
        raise WrongNumberLabwares.new("Expected #{num_labwares_manifest} labwares in Manifest but could only find #{num_labwares_file}.")
      end
    end
  end


  def read_from_database
    returned_list = {}
    manifest_model.labwares.each_with_index do |labware, pos|
      returned_list[pos.to_s] = {}
      if (labware.contents)
        returned_list[pos.to_s][:addresses] = labware.contents.keys.reduce({}) do |memo_address, address|
          memo_address[address] = {
            fields: labware.contents[address].keys.reduce({}) do |memo_field, field|
              memo_field[field] = {value: labware.contents[address][field]}
              memo_field
            end
          }
          memo_address
        end
      end
    end
    {:labwares => returned_list}
  end

  def read_from_raw
    idx = 0
    labware_id_schema_field =  manifest_schema_field(:labware_id)
    state_access[:raw].reduce({}) do |memo, row|
      mapped = mapped_row(row)

      validate_labware_existence(mapped, idx)


      labware_id = labware_id(mapped)

      memo[:labwares]={} unless memo[:labwares]
      labware_found = memo[:labwares].keys.select{|l| memo[:labwares][l][labware_id_schema_field]==labware_id }[0]
      unless labware_found
        labware_found = memo[:labwares].keys.length
        memo[:labwares][labware_found] = {}
      end

      validate_position_existence(mapped, idx)

      position = position(mapped)
      build_keys(memo, [:labwares, labware_found, :addresses])
      build_keys(memo, [:labwares, labware_found, :position])
      memo[:labwares][labware_found][:position] = labware_found
      build_keys(memo, [:labwares, labware_found, labware_id_schema_field])
      memo[:labwares][labware_found][labware_id_schema_field]=labware_id

      validate_position_duplication(memo, labware_found, position)

      build_keys(memo, [:labwares, labware_found, :addresses, position, :fields])


      memo[:labwares][labware_found][:addresses][position] = { fields:  mapped }
      idx = idx + 1
      memo
    end
  end


  def labware_id(mapped)
    if mapped[manifest_schema_field(:labware_id)]
      mapped[manifest_schema_field(:labware_id)][:value]
    else
      Rails.configuration.manifest_schema_config['default_labware_name_value']
    end
  end

  def position(mapped)
    if mapped[manifest_schema_field(:position)]
      mapped[manifest_schema_field(:position)][:value]
    else
      Rails.configuration.manifest_schema_config['default_position_value']
    end
  end


  def validate_labware_existence(mapped, idx)
    if (manifest_schema_field_required?(manifest_schema_field(:labware_id)) && !mapped[manifest_schema_field(:labware_id)])
      raise LabwareNotFound.new("This manifest does not have a valid labware id field for the labware at row: #{idx}")
    end
  end

  def validate_position_existence(mapped, idx)
    if (manifest_schema_field_required?(manifest_schema_field(:position)) && !mapped[manifest_schema_field(:position)])
      raise PositionNotFound.new("This manifest does not have a valid position field for the wells of row: #{idx}")
    end
  end


  def validate_position_duplication(obj, labware_id, position)
    if obj[:labwares][labware_id][:addresses].key?(position)
      raise PositionDuplicated.new("Duplicate entry found for #{labware_id}: Position #{position}")
    end
  end

  def mapped_row(row)
    row.keys.reduce({}) do |memo, key|
      observed_key = key.to_s
      expected_key = expected_matched_for_observed(observed_key)
      if expected_key
        build_keys(memo, [expected_key, :value])
        memo[expected_key][:value] = row[key]
      end
      memo
    end
  end

  def expected_matched_for_observed(key)
    @state[:mapping][:matched].select{|match| match[:observed] == key }.map{|m| m[:expected]}.first
  end

end
