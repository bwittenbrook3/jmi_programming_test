class CreateOrganismDrugBreakpoints < ActiveRecord::Migration
  def change
    create_table :organism_drug_breakpoints do |t|
      t.integer :organism_id, index: true
      t.integer :drug_id, index: true
      t.integer :clsi_breakpoint_id, index: true
      t.integer :priority

      t.timestamps null: false
    end
  end
end
