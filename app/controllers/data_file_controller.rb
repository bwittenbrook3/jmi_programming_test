class DataFileController < ApplicationController
  def upload
    DataFile.import(params[:file_upload][:upload].tempfile)
    redirect_to root_path
  end
end
