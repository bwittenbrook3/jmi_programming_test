class ClsiBreakpoint < ActiveRecord::Base
  has_many :surrogate_drug_assignments
  has_many :surrogate_drugs, through: :surrogate_drug_assignments
end
