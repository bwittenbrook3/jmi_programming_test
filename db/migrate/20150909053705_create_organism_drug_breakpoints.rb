class CreateOrganismDrugBreakpoints < ActiveRecord::Migration
  def change
    create_table :organism_drug_breakpoints do |t|
      t.integer :isolate_id
      t.integer :drug_id
      t.integer :csli_breakpoint_id

      t.timestamps null: false
    end
  end
end
