class ClaimSubmissionsController < ApplicationController
	before_action :authenticate_user!

	def index
		@contact = Contact.all
	end

	def find_submissions_by_user
		@email = params[:email]
		@contact = Contact.find_by_email(@email)
		@submissions = @contact.material_submissions.where.not(:status => MaterialSubmission.CLAIMED) unless @contact.nil?

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
