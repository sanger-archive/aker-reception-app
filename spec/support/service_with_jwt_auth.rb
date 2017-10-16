shared_examples_for 'service that validates credentials' do |actions|

  context 'checking controller actions' do
    HTTP_VERB = {
      :create => :post, :update=>:put, :destroy=>:delete 
    }
    [actions].flatten.compact.each do |action|
      context "for #{action}" do
        context 'when no credentials are included' do
          it 'redirects to the login page' do
            send (HTTP_VERB[action]||:get), action
            expect(response).to have_http_status(:redirect)
          end
        end

        context 'when credentials are wrong' do
          it 'redirects to the login page' do
            send (HTTP_VERB[action]||:get), action, {}, {headers: { :HTTP_X_AUTHORISATION => 'wrong' }}
            expect(response).to have_http_status(:redirect)
          end
        end

        context 'when credentials are right' do
          it 'remains in the same page' do
            @user = OpenStruct.new(:email => 'other@sanger.ac.uk', :groups => ['world'])
            allow(controller).to receive(:check_credentials)
            allow(controller).to receive(:current_user).and_return(@user)

            send (HTTP_VERB[action]||:get), action
            expect(response).to have_http_status(:success)
          end 
        end
      end
    end
  end
end