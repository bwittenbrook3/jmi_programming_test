class ChangeOrganismDrugBreakpointToNotNull < ActiveRecord::Migration
  def change
    change_column :organism_drug_breakpoints, :organism_id, :integer, :null => false
    change_column :organism_drug_breakpoints, :drug_id, :integer, :null => false
    change_column :organism_drug_breakpoints, :clsi_breakpoint_id, :integer, :null => false
    change_column :organism_drug_breakpoints, :priority, :integer, :null => false
  end
end
