require 'rails_helper'

RSpec.describe CompletedSubmissionsController, type: :controller  do
  it_behaves_like 'service that validates credentials', [:index]

  context 'when printing a submission' do
    setup do
      @user = OpenStruct.new(:email => 'other@sanger.ac.uk', :groups => %w[world team252])
      allow(controller).to receive(:check_credentials)
      allow(controller).to receive(:current_user).and_return(@user)

      @labwares = 2.times.map{ create :labware }
      @submission = create :material_submission, {
        labwares: @labwares, owner_email: @user.email, status: MaterialSubmission.ACTIVE
      }
      @printer = create :printer, {name: 'my name'}
      @params = {
          completed_submission_ids: [@submission.id],
          printer: {name: @printer.name}
      }
    end

    context 'when no submissions are selected' do
      it 'shows an error' do
        post :print, {}
        expect(response).to redirect_to(completed_submissions_url)
        expect(flash[:error]).to be_present
      end
    end

    context 'when the print is successful' do
      setup do
        allow(@printer).to receive(:print_submissions).and_return(true)
      end
      it 'displays a text telling that' do
        post :print, params: @params
        expect(response).to redirect_to(completed_submissions_url)
        expect(flash[:notice]).to be_present
      end

      it 'increments the count of prints for each labware printed' do
        labware_prints = @labwares.map(&:print_count)
        post :print, params: @params
        expect(@submission.labwares.map{|l| l.print_count}.zip(labware_prints).all? do |a,b|
          a==b
        end).to eq(true)
      end

      it 'changes the status of the submission' do
        post :print, params: @params
        @submission.reload
        expect(@submission.status).to eq(MaterialSubmission.PRINTED)
      end

      it 'redirects to the printing page' do
        post :print, params: @params
        expect(response).to have_http_status(:redirect)
      end

    end

  end

  context 'when dispatching a submission' do
    setup do
      @user = OpenStruct.new(:email => 'other@sanger.ac.uk', :groups => %w[world team252])
      allow(controller).to receive(:check_credentials)
      allow(controller).to receive(:current_user).and_return(@user)

      @labwares = 2.times.map{ create :labware }
    end
    context 'when no submission has been selected' do
      it 'shows an error' do
        post :dispatch_submission, params: { completed_submission_ids: [] }
        expect(flash[:error]).to be_present
      end
    end
    context 'when the submission has not been printed before' do
      let(:submission) { create :material_submission, {
          labwares: @labwares, owner_email: @user.email, status: MaterialSubmission.ACTIVE
        }
      }
      it 'does not dispatch the submission' do
        post :dispatch_submission, params: { dispatched_submission_ids: [submission.id] }
        expect(submission.dispatched?).to eq(false)
      end
    end
    context 'when the submission was printed before' do
      let(:submission) { create :material_submission, {
          labwares: @labwares, owner_email: @user.email, status: MaterialSubmission.PRINTED
        }
      }
      it 'selects the submission as dispatched' do
        post :dispatch_submission, params: { dispatched_submission_ids: [submission.id] }
        submission.reload
        expect(submission.dispatched?).to eq(true)
      end

    end
  end

end
