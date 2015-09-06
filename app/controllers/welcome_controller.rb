class WelcomeController < ApplicationController
  def index
    @organisms = Organism.all
    @isolates_by_organism_code = Isolate.all.group_by(&:organism_code)
  end
end
