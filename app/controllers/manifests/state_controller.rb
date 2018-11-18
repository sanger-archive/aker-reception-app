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
    @transformer ||= Transformers::StateToState.new(state: manifest_state, manifest_model: manifest_model)
  end

  # manifest_file is an uploaded file. Will be an instance of ruby IO class (probably File).
  def manifest_state
    params[:state]
  end

  # manifest_model is the instance of the manifest model that we are currently building
  def manifest_model
    @manifest ||= Manifest.find(params[:manifest_id])
  end


end
