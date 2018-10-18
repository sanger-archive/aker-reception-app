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
    @transformer ||= Transformers::ExcelToArray.new(path: manifest_path)
  end

  def manifest_path
    manifest.path
  end

  # manifest is an uploaded file. Will be an instance of ruby IO class (probably File).
  def manifest
    params[:manifest]
  end
end
