class ChangeToNonNullableFieldsInMicResult < ActiveRecord::Migration
  def change
    change_column :mic_results, :isolate_id, :integer, :null => false
    change_column :mic_results, :drug_id, :integer, :null => false
    change_column :mic_results, :mic_value, :decimal, precision: 9, scale: 5, :null => false
    change_column :mic_results, :mic_edge, :integer, :null => false
  end
end
