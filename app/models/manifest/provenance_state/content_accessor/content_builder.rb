module Manifest::ProvenanceState::ContentAccessor::ContentBuilder

  class ContentError < StandardError ; end
  class PositionNotFound < ContentError ; end
  class LabwareNotFound < ContentError ; end
  class PositionDuplicated < ContentError ; end
  class WrongNumberLabwares < ContentError ; end

  def validate_labware_existence(mapped, idx)
    unless mandatory_field_value_present(mapped, :labware_id)
      raise LabwareNotFound.new("This manifest file does not have a valid labware id field for the labware at line: #{idx+1}")
    end
  end

  def validate_position_existence(mapped, idx)
    unless mandatory_field_value_present(mapped, :position)
      raise PositionNotFound.new("This manifest file does not have a valid position field for the wells of line: #{idx+1}")
    end
  end


  def validate_position_duplication(obj, labware_id, position)
    if obj[:labwares][labware_id][:addresses].key?(position)
      raise PositionDuplicated.new("Duplicate entry found for #{labware_id}: Position #{position}")
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
    state_access[:raw].reduce({}) do |memo, row|

      mapped = mapped_row(row)

      validate_labware_existence(mapped, idx)


      labware_id = labware_id(mapped)
      labware_found = _find_or_allocate_labware_from_raw(memo, labware_id)

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
    key = manifest_schema_field(:labware_id)
    if mapped[key]
      mapped[key][:value]
    else
      Rails.configuration.manifest_schema_config['default_labware_name_value']
    end
  end

  def position(mapped)
    key = manifest_schema_field(:position)
    if mapped[key]
      mapped[key][:value]
    else
      Rails.configuration.manifest_schema_config['default_position_value']
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

  def labware_id_schema_field
    manifest_schema_field(:labware_id).to_sym
  end

  def mandatory_field_value_present(mapped, field)
    return true unless manifest_schema_field_required?(manifest_schema_field(field))
    (mapped[manifest_schema_field(field)] && !mapped[manifest_schema_field(field)][:value].blank?)
  end

  def expected_matched_for_observed(key)
    @state[:mapping][:matched].select{|match| match[:observed] == key }.map{|m| m[:expected]}.first
  end

  def _find_or_allocate_labware_from_raw(memo, labware_id)
    memo[:labwares]={} unless memo[:labwares]
    labware_found = memo[:labwares].keys.select{|l| memo[:labwares][l][labware_id_schema_field]==labware_id }[0]
    unless labware_found
      labware_found = memo[:labwares].keys.length
      memo[:labwares][labware_found] = {}
    end
    labware_found
  end

end
