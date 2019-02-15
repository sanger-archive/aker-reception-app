require 'active_support/core_ext/module/delegation'

class Manifest::ProvenanceState::ContentAccessor < Manifest::ProvenanceState::Accessor
  delegate :manifest_schema_field, to: :provenance_state
  delegate :manifest_schema_field_required?, to: :provenance_state
  delegate :manifest_model, to: :provenance_state

  include ContentMessageStore
  include ContentBuilder

  def rebuild?
    (state_access && (state_access[:rebuild] == true))
  end

  def present_mapping?
    (@state && @state[:mapping])
  end

  def valid_mapping?
    (@state && @state[:mapping] && (@state[:mapping][:valid] == true))
  end

  def present_mapping_tool?
    present_mapping? && @state[:mapping][:shown]
  end

  def present_raw?
    (state_access.key?(:raw) && !state_access[:raw].nil?)
  end

  def present_structured?
    (state_access && state_access.key?(:structured) && !state_access[:structured].nil?)
  end


  def present?
    super && present_structured?
  end

  def state_access_raw
    state_access && state_access[:raw]
  end

  def build
    {
      raw: state_access_raw,
      structured: build_structured
    }
  end

  def build_structured
    if (state_access_raw && valid_mapping?)
      read_from_raw
    else
      read_from_database
    end
  end

  def num_labwares_manifest
    manifest_model.labwares.count
  end

  def validate
    if state_access[:structured] && state_access[:structured][:labwares]
      num_labwares_file = state_access[:structured][:labwares].keys.length
      if (num_labwares_file > num_labwares_manifest)
        raise WrongNumberLabwares.new("Expected #{num_labwares_manifest} labwares in Manifest but found #{num_labwares_file}.")
      elsif (num_labwares_file < num_labwares_manifest)
        raise WrongNumberLabwares.new("Expected #{num_labwares_manifest} labwares in Manifest but could only find #{num_labwares_file}.")
      end
    end
    state_access[:valid]=true
  end

end
