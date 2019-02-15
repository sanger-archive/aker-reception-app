class Manifests::UploadController < ApplicationController

  # POST /manifests/upload
  def create
    render transformed_response.response
  end

private

  def transformed_response
    @transformed_response ||= TransformedResponse.new(transformer: transformer)
  end

  def transformer
    @transformer ||= Transformers::ExcelToState.new(path: manifest_file.path,
      manifest_model: manifest_model, current_user: current_user)
  end

  # manifest_file is an uploaded file. Will be an instance of ruby IO class (probably File).
  def manifest_file
    params[:manifest]
  end

  # manifest_model is the instance of the manifest model that we are currently building
  def manifest_model
    @manifest ||= Manifest.find(params[:manifest_id])
  end


end
