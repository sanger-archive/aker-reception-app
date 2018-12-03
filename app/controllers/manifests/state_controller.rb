class Manifests::StateController < ApplicationController

  # PUT /manifests/state
  def update
    render transformed_response.response
  end

private

  def transformed_response
    @transformed_response ||= TransformedResponse.new(transformer: transformer)
  end

  def transformer
    @transformer ||= Transformers::StateToState.new(state: manifest_state, manifest_model: manifest_model,
      current_user: current_user)
  end

  # manifest_file is an uploaded file. Will be an instance of ruby IO class (probably File).
  def manifest_state
    {
      schema: valid_params[:schema],
      manifest: valid_params[:manifest],
      content: valid_params[:content],
      mapping: valid_params[:mapping],
      services: valid_params[:services]
    }
  end

  def valid_params
    params.permit(:id, schema: {}, manifest: {}, content: {}, mapping: {}, services: {})
  end

  # manifest_model is the instance of the manifest model that we are currently building
  def manifest_model
    @manifest ||= Manifest.find(params[:id])
  end


end
