class DataFileController < ApplicationController
  def upload
    unless params[:file_upload].nil?
      ClsiBreakpoint.delete_all
      Drug.delete_all
      Isolate.delete_all
      IsolateDrugReaction.delete_all
      MicResult.delete_all
      Organism.delete_all
      SurrogateDrugAssignment.delete_all

      DataFile.import(params[:file_upload][:upload].tempfile) 
    end

    respond_to do |format|
      format.js
    end 
  end

  def upload_status
    if Delayed::Job.all.count > 0
      respond_to do |format|
        format.json { head :ok }
      end
    else
      # File processed...
      @organisms = Organism.all
      @isolates_by_organism_code = Isolate.all.group_by(&:organism_code)
      respond_to do |format|
        format.js
      end
    end
  end
end
