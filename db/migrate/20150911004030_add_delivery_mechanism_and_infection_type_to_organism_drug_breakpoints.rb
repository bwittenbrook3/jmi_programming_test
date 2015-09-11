class AddDeliveryMechanismAndInfectionTypeToOrganismDrugBreakpoints < ActiveRecord::Migration
  def change
    add_column :organism_drug_breakpoints, :delivery_mechanism, :string
    add_column :organism_drug_breakpoints, :infection_type, :string
  end
end
