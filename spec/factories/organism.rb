FactoryGirl.define do
  factory :organism do 
    
    code "CF"
    name "Citrobacter freundii"
    genus "Citrobacter"
    species "freundii"
    sub_species "NULL"
    group "Citrobacter spp."
    master_group "Enteric"
    viridans_group "NULL"
    level_1_class "Enteric"
    level_2_class "Citrobacter spp."
    level_3_class "Citrobacter freundii species complex"
    level_4_class "NULL"

    factory :alternate_organism do
      code "SA"
      name "Staphylococcus aureus"
      genus "Staphylococcus"
      species "aureus"
      sub_species "NULL"
      group "Citrobacter spp."
      master_group "Enteric"
      viridans_group "NULL"
      level_1_class "Staphylococci"
      level_2_class "Staphylococcus aureus"
      level_3_class "NULL"
      level_4_class "NULL"
    end

  end
end