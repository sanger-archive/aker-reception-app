class UpdateManifestService

  def initialize(manifest, messages)
    @manifest = manifest
    @messages = messages
  end

  def ready_for_step(step)
    step = step.to_sym
    unless @manifest.pending?
      return fail("This Manifest cannot be updated.")
    end
    return true if step==:labware
    unless @manifest.labwares.present? && !(@manifest.supply_labwares.nil?)
      return fail("Please go back and complete the labware step before proceeding.")
    end
    return true if step==:provenance
    unless @manifest.after_provenance?
      return fail("Please go back and complete the provenance step before proceeding.")
    end
    return true if step==:ethics
    unless @manifest.ethical?
      return fail("Please go back and complete the ethics step before proceeding.")
    end
    return true
  end

private

  def fail(message)
    @messages[:error] = message
    return false
  end
end
