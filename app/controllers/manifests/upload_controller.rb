class Manifests::UploadController < ApplicationController

  # POST /manifests/create
  def create
    render transformed_response.response
  end

private

  def transformed_response
    @transformed_response ||= TransformedResponse.new(transformer: transformer)
  end

  def transformer
    @transformer ||= Transformers::ExcelToCsv.new(path: manifest_path)
  end

  def manifest_path
    manifest.path
  end

  def manifest
    params[:manifest]
  end
end
