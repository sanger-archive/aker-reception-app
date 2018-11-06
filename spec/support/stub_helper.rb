module StubHelper

  def stub_matcon_client_schema
    allow(MatconClient::Material).to receive(:schema).and_return(JSON.parse(file_fixture('material_schema.json').read))
  end
end
