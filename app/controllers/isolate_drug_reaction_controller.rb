class IsolateDrugReactionController < ApplicationController
  def index
    @drugs = Drug.all 
    @isolates = Isolate.all 
  end

  def create
    redirect_to show_isolate_drug_reaction_index_path(params[:isolate_drug_reaction][:drug_id], params[:isolate_drug_reaction][:isolate_id])
  end

  def show
    drug_id = params[:drug_id]
    isolate_id = params[:isolate_id]
    @drug = Drug.find(drug_id)
    @isolate = Isolate.find(isolate_id)
  end
end
