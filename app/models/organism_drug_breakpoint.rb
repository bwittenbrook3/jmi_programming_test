class OrganismDrugBreakpoint < ActiveRecord::Base
  belongs_to :organism 
  belongs_to :drug 
  belongs_to :clsi_breakpoint

  validates_presence_of :clsi_breakpoint_id
  validates_presence_of :organism_id
  validates_presence_of :drug_id
  validates_presence_of :priority
  validates_uniqueness_of :clsi_breakpoint_id, scope: [:organism_id, :drug_id, :delivery_mechanism, :infection_type]
end
