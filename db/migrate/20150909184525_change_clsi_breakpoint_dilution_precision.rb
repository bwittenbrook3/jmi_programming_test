class ChangeClsiBreakpointDilutionPrecision < ActiveRecord::Migration
  def change
    change_column :clsi_breakpoints, :s_maximum, :decimal, precision: 9, scale: 5
    change_column :clsi_breakpoints, :r_minimum, :decimal, precision: 9, scale: 5
  end
end
