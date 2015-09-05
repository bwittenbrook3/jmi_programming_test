class DataFileController < ApplicationController
  def upload
    DataFile.import(params[:file_upload][:upload].tempfile)
    redirect_to :upload_data_file
  end

  def view

  end
end
