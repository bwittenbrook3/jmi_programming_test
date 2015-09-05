class Drug < ActiveRecord::Base
  has_many :clsi_breakpoints
  has_many :mic_results
end
