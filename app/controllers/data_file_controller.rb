class DataFileController < ApplicationController
  def upload
    DataFile.import(params[:file_upload][:upload].tempfile)
    redirect_to :isloate_drug_reactions
  end

  def view

  end
end
