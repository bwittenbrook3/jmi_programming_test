class CreateIsolates < ActiveRecord::Migration
  def change
    create_table :isolates do |t|
      t.integer :collection_no
      t.integer :site_id
      t.integer :study_year
      t.integer :bank_no
      t.string :organism_code

      t.timestamps null: false
    end
  end
end
