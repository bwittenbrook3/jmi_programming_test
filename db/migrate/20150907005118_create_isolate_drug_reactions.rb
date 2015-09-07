class CreateIsolateDrugReactions < ActiveRecord::Migration
  def change
    create_table :isolate_drug_reactions do |t|
      t.string :authority
      t.string :publication
      t.string :delivery_mechanism
      t.string :infection_type
      t.integer :isolate_id
      t.integer :drug_id
      t.string :reaction
      t.string :footnote
      t.string :eligible_interpretations
      t.integer :rule_row_number
      t.string :used_surrogate_drug_id
      t.string :used_surrogate_drug_ordinal
      t.string :used_surrogate_rule_type

      t.timestamps null: false
    end
  end
end
