class ClaimSubmissionsController < ApplicationController

	def index
		@email = current_user.email
		@contact = Contact.find_by_email(@email)
		if @contact.nil?
			@submissions = []
		else
			@submissions = @contact.material_submissions.where.not(:status => MaterialSubmission.CLAIMED)
		end
	end

	def find_submissions_by_user
		if @contact.nil? || @submissions.empty?
		  @json = {:error => 'No submissions found'}
		else
		  @json = @submissions.to_json
		end
		render json: @json
	end

	def get_all_collections
		collection_uuids = StudyClient::Collection.all.map { |n| n.set_id }
		render json: SetClient::Set.get_set_names(collection_uuids).to_json
	end

end
