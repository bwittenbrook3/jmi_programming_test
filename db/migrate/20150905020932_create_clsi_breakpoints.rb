class CreateClsiBreakpoints < ActiveRecord::Migration
  def change
    create_table :clsi_breakpoints do |t|
      t.integer :drug_id
      t.decimal :s_maximum
      t.decimal :r_minimum
      t.integer :surrogate_id
      t.string :r_if_surrogate_is
      t.string :ni_if_surrogate_is
      t.string :r_if_blt_is
      t.string :delivery_mechanism
      t.string :infection_type
      t.string :footnote

      t.timestamps null: false
    end
  end
end
