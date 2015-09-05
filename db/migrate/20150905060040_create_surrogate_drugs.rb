class CreateSurrogateDrugs < ActiveRecord::Migration
  def change
    create_table :surrogate_drug_assignments do |t|
      t.integer :clsi_breakpoint_id
      t.integer :surrogate_drug_id

      t.timestamps null: false
    end
  end
end
