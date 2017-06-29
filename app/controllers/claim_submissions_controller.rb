class ClaimSubmissionsController < ApplicationController

  def index
    @email = current_user.email
    @contact = Contact.find_by_email(@email)
    if @contact.nil?
      @submissions = []
    else
      @submissions = @contact.material_submissions.where(:status => MaterialSubmission.PRINTED).select(&:ready_for_claim?)
    end
  end

  def get_all_collections
    collection_uuids = StudyClient::Collection.all.map { |n| n.set_id }
    render json: SetClient::Set.get_set_names(collection_uuids).to_json
  end

  def claim
    cp = claim_params
    sub_ids = cp[:submission_ids]
    col_id = cp[:collection_id]
    submissions = MaterialSubmission.where(id: sub_ids)
    not_ready = submissions.reject(&:ready_for_claim?).map { |s| "Submission #{s.id}" }
    unless not_ready.empty?
      flash[:error] = "Some submissions cannot be claimed at this time: #{not_ready}"
      return
    end
    material_ids = submissions_material_ids(submissions)
    SetClient::Set.find(col_id).first.set_materials(material_ids)
    material_ids.each { |mid| MatconClient::Material.new(_id: mid).update_attributes(available: true) }
    submissions.each(&:claim_claimable_labwares)
  end

  private

  def claim_params
    {
      submission_ids: params.require(:submission_ids),
      collection_id: params.require(:collection_id),
    }
  end

  def submissions_material_ids(submissions)
    submissions.flat_map(&:labwares).select(&:ready_for_claim?).flat_map { |lw| lw.contents.values }.flat_map { |bio_data| bio_data['id'] }
  end

end
