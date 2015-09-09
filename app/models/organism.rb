class Organism < ActiveRecord::Base
  has_many :organism_drug_breakpoints
  has_many :csli_breakpoints, through: :organism_drug_breakpoints
end
