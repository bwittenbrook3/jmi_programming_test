FactoryGirl.define do
  factory :clsi_breakpoint do 
    master_group_include "Enteric"

    factory :standard_breakpoint do 
      s_maximum 1.0
      r_minimum 4.0
    end

    factory :no_r_minimum_breakpoint do 
      s_maximum 1.0
    end

    # case where there's zero dilutions between s_max and r_min
    factory :zero_dilution_breakpoint do
      s_maximum 2.0
      r_minimum 4.0
    end

    # case where there's one dilution between s_max and r_min
    factory :one_dilution_breakpoint do
      s_maximum 2.0
      r_minimum 8.0
    end

    # case where there's two dilutions between s_max and r_min
    factory :two_dilution_breakpoint do
      s_maximum 2.0
      r_minimum 16.0
    end

  end
end