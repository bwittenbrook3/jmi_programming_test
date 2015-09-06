class CreateMicResults < ActiveRecord::Migration
  def change
    create_table :mic_results do |t|
      t.integer :isolate_id
      t.integer :drug_id
      t.decimal :mic_value, precision: 10 , scale: 2
      t.integer :mic_edge

      t.timestamps null: false
    end
  end
end
