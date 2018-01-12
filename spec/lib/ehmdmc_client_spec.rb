require 'rails_helper'

require 'ehmdmc_client'

RSpec.describe 'EHMDMCClient' do

  context 'EHMDMCClient' do

    context '#get_response_for_hmdmc' do
      let(:connection) { double('connection')}
      let(:response) { double('response') }
      before do
        allow(Faraday).to receive(:new).and_return(connection)
      end

      it 'returns a connection when successful' do
        allow(connection).to receive(:get).and_return(response)
        val = EHMDMCClient.get_response_for_hmdmc('1234')
        expect(val).to eq(response)
      end
      it 'returns nil when connection failed' do
        allow(connection).to receive(:get).and_raise(Faraday::ConnectionFailed, 'some desc')
        val = EHMDMCClient.get_response_for_hmdmc('1234')
        expect(val).to eq(nil)
      end      
    end

    context '#validate_hmdmc' do
      let(:connection) { double('connection')}
      let(:hmdmc) { '1234'}
      let(:response) { double('response') }
      before do
        allow(Faraday).to receive(:new).and_return(connection)
      end
      context 'when the connection fails' do
        it 'returns a service failed message' do
          allow(connection).to receive(:get).and_raise(Faraday::ConnectionFailed, 'some desc')
          msg = EHMDMCClient.validate_hmdmc(hmdmc)
          expect(msg.text).to include('service failed')
        end
      end
      context 'when the connection is right' do
        before do
          allow(connection).to receive(:get).and_return(response)
        end

        context 'when the http code is not 200' do
          before do
            allow(response).to receive(:status).and_return(500)
          end
          it 'returns a status code message' do
            msg = EHMDMCClient.validate_hmdmc(hmdmc)
            expect(msg.text).to include('status code')
          end          
        end

        context 'when the http code is 200' do
          before do
            allow(response).to receive(:status).and_return(200)
            allow(response).to receive(:body).and_return("{}")
          end

          context 'when there is a json parsing error' do
            before do
              allow(JSON).to receive(:parse).and_raise(JSON::ParserError)  
            end
            it 'returns a invalid JSON message' do
              msg = EHMDMCClient.validate_hmdmc(hmdmc)
              expect(msg.text).to include('invalid JSON')              
            end
          end

          context 'when the parsing is correct' do           
            context 'when valid attribute is not set to true by the hmdmc service' do
              let(:json_object) { { valid: false, errorcode: 1 }.to_json }  
              before do
                allow(response).to receive(:body).and_return(json_object)
              end
              it 'returns a rejected message' do
                msg = EHMDMCClient.validate_hmdmc(hmdmc)
                expect(msg.text).to include('rejected')
              end
              it 'indicates that is not valid' do
                msg = EHMDMCClient.validate_hmdmc(hmdmc)
                expect(msg.valid?).to eq(false)
              end
              it 'indicates that is validated' do
                msg = EHMDMCClient.validate_hmdmc(hmdmc)
                expect(msg.is_validated?).to eq(true)
              end

            end
            context 'when valid attribute is set to true by the hmdmc service' do
              let(:json_object) { { valid: true, errorcode: 1 }.to_json }  
              before do
                allow(response).to receive(:body).and_return(json_object)
              end
              it 'returns a nil message' do
                msg = EHMDMCClient.validate_hmdmc(hmdmc)
                expect(msg.text).to eq(nil)
              end

              it 'indicates that is valid' do
                msg = EHMDMCClient.validate_hmdmc(hmdmc)
                expect(msg.valid?).to eq(true)
              end
              it 'indicates that is validated' do
                msg = EHMDMCClient.validate_hmdmc(hmdmc)
                expect(msg.is_validated?).to eq(true)
              end

            end

          end
        end

      end
    end
  end

  context 'EHMDMCClient::Validation' do
    let(:hmdmc) { '1234' }
    let(:obj) { EHMDMCClient::Validation.new(hmdmc) }
    let(:msg) { 'some text' }
    let(:generic_msg) { "The HMDMC #{hmdmc} is considered as not valid by the HMDMC service" }
    before do
      Rails.logger = double('logger')
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    context '#to_json' do
      context 'if the hmdmc has not been validated' do
        before do
          obj.load_message(:user_message, :info, 'some problem', false)
        end
        it 'does not generate a json with the valid field' do
          m = JSON.parse(obj.to_json).symbolize_keys
          expect(m[:valid]).to eq(nil)
        end
      end
      context 'if the hmdmc has been validated' do
        before do
          obj.load_message(:user_message, :info, 'some problem', true)
        end        
        it 'does generates a json with the valid field' do
          m = JSON.parse(obj.to_json).symbolize_keys
          expect(m[:valid]).to eq(false)
        end
      end      
    end

    context '#load_message' do
      it 'returns the same instance' do
        msg = obj.load_message(:user_message, :info,'some msg',false)
        expect(obj).to eq(msg)
      end

      context 'with argument: facility' do
        context 'when the facility specified is :info' do
          it 'writes the message to Rails.logger.info' do
            obj.load_message(:infrastructure_message, :info, msg,true)
            expect(Rails.logger).to have_received(:info).with(msg)
          end
        end

        context 'when the facility specified is :error' do
          it 'writes the message to Rails.logger.error' do
            obj.load_message(:infrastructure_message, :error, msg,true)
            expect(Rails.logger).to have_received(:error).with(msg)
          end
        end
      end

      context 'with argument: type_of_message' do
        context ':user_message' do
          before do
            obj.load_message(:user_message, :info, msg, true)
          end
          it 'sets the loaded message for the user' do
            expect(obj.error_message).to eq(msg)
          end
        end
        context ':infrastructure_message' do
          before do
            obj.load_message(:infrastructure_message, :info, msg, true)
          end
          it 'sets a generic message for the user' do
            expect(obj.error_message).to eq(generic_msg)
          end
        end
      end

      context 'with argument: valid' do
        context 'when no messages have been loaded' do
          it 'marks the message as valid' do
            expect(obj.valid?).to eq(true)
          end
          it 'identifies the message as validated' do
            expect(obj.is_validated?).to eq(true)
          end                      
        end
        context 'when a message has been previously loaded' do
          context 'when the loaded message is identified as not validated' do
            before do
              obj.load_message(:infrastructure_message, :info, nil, false)
            end
            it 'does not mark the message as valid' do
              expect(obj.valid?).to eq(false)
            end
            it 'identifies the message as not validated' do
              expect(obj.is_validated?).to eq(false)
            end            
          end
          context 'when the loaded message is identified as validated' do
            context 'when some text was added by the message' do
              before do
                obj.load_message(:infrastructure_message, :info, 'some error', true)
              end
              it 'marks the message as invalid' do
               expect(obj.valid?).to eq(false) 
              end
              it 'identifies the message as validated' do
                expect(obj.is_validated?).to eq(true)
              end              
            end
            context 'when no text is stored' do
              before do
                obj.load_message(:infrastructure_message, :info, nil, true)
              end
              it 'marks the message as valid ' do
               expect(obj.valid?).to eq(true) 
              end
              it 'identifies the message as validated' do
                expect(obj.is_validated?).to eq(true)
              end              
            end
          end
        end
      end
    end
  end
end