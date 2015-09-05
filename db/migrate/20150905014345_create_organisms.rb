class CreateOrganisms < ActiveRecord::Migration
  def change
    create_table :organisms do |t|
      t.string :organism_code
      t.string :organism_name
      t.string :genus
      t.string :species
      t.string :sub_species
      t.string :organism_group
      t.string :master_group
      t.string :viridans_group
      t.string :level_1_class
      t.string :level_2_class
      t.string :level_3_class
      t.string :level_4_class

      t.timestamps null: false
    end
  end
end
