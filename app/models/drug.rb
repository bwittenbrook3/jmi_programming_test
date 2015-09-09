class Drug < ActiveRecord::Base
  has_many :isolate_drug_breakpoints
  has_many :clsi_breakpoints, through: :isolate_drug_breakpoints
  
  has_many :mic_results
end
