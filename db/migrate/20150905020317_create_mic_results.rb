class CreateMicResults < ActiveRecord::Migration
  def change
    create_table :mic_results do |t|
      t.integer :isolate_id
      t.integer :drug_id
      t.decimal :mic_value
      t.integer :mic_edge

      t.timestamps null: false
    end
  end
end
