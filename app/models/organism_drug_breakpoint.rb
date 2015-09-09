class OrganismDrugBreakpoint < ActiveRecord::Base
  belongs_to :organism 
  belongs_to :drug 
  belongs_to :csli_breakpoint
end
