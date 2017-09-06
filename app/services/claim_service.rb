=begin

This is class is responsible for the action of "Claiming" a list of Material Submissions
Claiming involves 4 steps

0. Rejecting any submissions that aren't ready_for_claim?
1. Setting claimable labwares' claimed attribute
2. Applying a Stamp to materials in the claimable labwares
3. Setting claimable labwares' materials' available attribute to true

If anything goes wrong, a message will be put onto the error attribute

=end

class ClaimService

  attr_reader :submissions, :stamp_id
  attr_accessor :error

  def initialize(submissions, stamp_id)
    @submissions = submissions
    @stamp_id    = stamp_id
  end

  def process
    # 0.
    not_ready = submissions.reject(&:ready_for_claim?)

    unless not_ready.empty?
      friendly_submissions = not_ready.map { |s| "Submission #{s.id}" }.join(", ")
      self.error = "Some submissions cannot be claimed at this time: #{friendly_submissions}"
      return false
    end

    begin
      # 1. + 2. + 3.
      DispatchService.new.process([
        DispatchSteps::StampSubmissionMaterialsStep.new(material_ids, stamp_id),
        DispatchSteps::UpdateMaterialsToAvailableStep.new(material_ids),
        DispatchSteps::ClaimClaimableLabware.new(submissions)
      ])
    rescue => e
      self.error = e.message
      return false
    end

    return true
  end

private

  # Returns material ids for claimable labwares in each submission
  def material_ids
    submissions.flat_map(&:labwares).select(&:ready_for_claim?).flat_map { |lw| lw.contents.values }.flat_map { |bio_data| bio_data['id'] }
  end

end