class WelcomeController < ApplicationController
  def index
    @organisms = Organism.all
    @isolates_by_organism_code = Isolate.all.group_by(&:organism_code)
  end

  def download_isolate_drug_reactions
    @mic_results = MicResult.all
    respond_to do |format|
      format.xlsx
    end
  end
end
