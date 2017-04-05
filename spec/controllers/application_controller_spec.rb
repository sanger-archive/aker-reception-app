require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do

    describe "JWT Auth Header" do
        context "When calling the set-service" do
            it "sets the authorization header by using the session" do
                jsontype = 'application/vnd.api+json'
                principle_user = {data: 'some_info'}
                RequestStore.store[:x_authorisation] = principle_user
                srequ = stub_request(:get, "#{Rails.configuration.set_url}sets").
                    with(headers: { 'Accept' => jsontype,
                        'Content-Type' => jsontype,
                        'X-Authorisation' => JWTSerializer.generate_jwt(principle_user)}).
                    to_return(status: 200, body: "", headers: {})
                SetClient::Set.all
                assert_requested(srequ)
            end
        end
    end
end
