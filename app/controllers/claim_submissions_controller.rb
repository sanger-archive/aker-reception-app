class ClaimSubmissionsController < ApplicationController

  def index
    @stamps = StampClient::Stamp.all

    @email = current_user.email
    @contact = Contact.find_by_email(@email)
    if @contact.nil?
      @submissions = []
    else
      @submissions = @contact.material_submissions.where(:status => MaterialSubmission.PRINTED).select(&:ready_for_claim?).sort_by(&:id).reverse
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
    stamp_id = cp[:stamp_id]
    submissions = MaterialSubmission.where(id: sub_ids)
    not_ready = submissions.reject(&:ready_for_claim?).map { |s| "Submission #{s.id}" }
    unless not_ready.empty?
      flash[:error] = "Some submissions cannot be claimed at this time: #{not_ready}"
      return
    end
    material_ids = submissions_material_ids(submissions)

    begin
      stamp = StampClient::Stamp.find(stamp_id).first
      stamp.apply_to(material_ids)
    rescue JsonApiClient::Errors::AccessDenied
      raise AkerPermissionGem::NotAuthorized.new('You cannot set a stamp of permissions to the materials because you do not have the ownership of the materials you want to claim')
    end

    SetClient::Set.find(col_id).first.set_materials(material_ids)

    material_ids.each { |mid| MatconClient::Material.new(_id: mid).update_attributes(available: true) }

    submissions.each(&:claim_claimable_labwares)
  end

  helper_method :stamp_summary

  def stamp_summary(stamp)
    "Stamp #{stamp.name} from #{stamp.owner_id}"
  end

  private

  def claim_params
    {
      submission_ids: params.require(:submission_ids),
      collection_id: params.require(:collection_id),
      stamp_id: params.require(:stamp_id)
    }
  end

  def submissions_material_ids(submissions)
    submissions.flat_map(&:labwares).select(&:ready_for_claim?).flat_map { |lw| lw.contents.values }.flat_map { |bio_data| bio_data['id'] }
  end

end
