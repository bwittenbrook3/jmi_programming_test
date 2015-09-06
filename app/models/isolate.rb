class Isolate < ActiveRecord::Base
  has_many :mic_results

  def organism
    return Organism.where(code: self.organism_code).first
  end
end
