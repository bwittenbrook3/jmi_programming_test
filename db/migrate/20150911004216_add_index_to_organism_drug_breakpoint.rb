class AddIndexToOrganismDrugBreakpoint < ActiveRecord::Migration
  def change
    add_index :organism_drug_breakpoints, [:organism_id, :drug_id, :clsi_breakpoint_id, :delivery_mechanism, :infection_type], unique: true, name: "index_drug_organism_breakpoint"
  end
end
