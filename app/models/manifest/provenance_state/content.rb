require 'active_support/core_ext/module/delegation'

class Manifest::ProvenanceState::Content < Manifest::ProvenanceState::Accessor
  delegate :manifest_schema_field, to: :provenance_state

  def apply(state = nil)
    @state = state if state
    _build_content
  end

  def valid?
    @state.key?(:content) && @state[:content].key?(:structured)
  end

  class PositionError < StandardError ; end

  private

  def _build_content
    @state[:content] = {} unless @state[:content]
    unless @state[:content][:structured]
      @state[:content][:structured] = {valid: false}
      if @state[:content][:raw] && @state[:mapping]
        @state[:content][:structured] = _content_from_raw
      end
    end
  end

  def build_keys(obj, list)
    list.reduce(obj) do |memo, e|
      memo[e]={} unless memo[e]
      memo[e]
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

  def _content_from_raw
    @state[:content][:raw].reduce({}) do |memo, row|
      mapped = mapped_row(row)
      labware_id = labware_id(mapped)
      position = position(mapped)
      build_keys(memo, [:labwares, labware_id, :addresses])

      validate_position(memo, labware_id, position)

      build_keys(memo, [:labwares, labware_id, :addresses, position, :fields])
      memo[:labwares][labware_id][:addresses][position] = { fields:  mapped }
      memo
    end
  end

  def validate_position(obj, labware_id, position)
    if obj[:labwares][labware_id][:addresses].key?(position)
      raise PositionError.new("Duplicate entry found for #{labware_id}: Position #{position}")
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
