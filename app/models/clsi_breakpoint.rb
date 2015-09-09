class ClsiBreakpoint < ActiveRecord::Base
  has_one :isolate_drug_breakpoint
  has_one :drug, through: :isolate_drug_breakpoint

  has_many :surrogate_drug_assignments
  has_many :surrogate_drugs, through: :surrogate_drug_assignments

  after_create :related_organism_codes

  def analyze(mic_result)
    # Return nil if no mic_result is supplied
    return nil if mic_result.nil?

    results = Hash.new

    # Identify the sucesseptability between the drug and the isolate tested
    @isolate = mic_result.isolate
    surrogate_drug_reaction_interpretations = interpret_surrogate_drug_reactions(@isolate)
    

    # Identify eligible interpretations between the drug and the isolate based on
    # this CLSI breakpoint.
    results[:eligible_interpretations] = determine_eligible_interpretations

    reaction = interpret_reaction(mic_result, surrogate_drug_reaction_interpretations)
    results[:interpretation] = reaction[:interpretation]


    return results
  end

  # JASON: outer loop calling this method is looping over all mic results
  # JASON: This method returns all breakpoints that apply to the current
  # JASON: isolate's orgcode and current mic result's drug
  # JASON: (may be multiple ones if there are different authorities/
  # JASON: publications/ delivery mechanisms/infection types)
  # JASON: should split breakpoint.related_organism_codes column into
  # JASON: sub table and add database constraint so can only have one
  # JASON: breakpoint rule defined for any given combination of
  # JASON: auth/pub/deliv/infec/orgcode/drug
  def self.determine_breakpoint(isolate, drug)
    return nil if isolate.nil? || drug.nil?
    breakpoints = []
    drug.clsi_breakpoints.each do |breakpoint|
      puts breakpoint.related_organism_codes
      if breakpoint.related_organism_codes.split(", ").include?(isolate.organism_code)
        breakpoints << breakpoint
      end
    end
    return breakpoints
  end

  def related_organism_codes
    return related_organism_codes_list unless related_organism_codes_list.nil?
    organisms_codes = []

    # master_group_include
    unless master_group_include.nil?
      Organism.where(master_group: master_group_include).pluck(:code).each do |organism_code|
        organisms_codes << organism_code
      end
    end

    # organism_group_include
    unless organism_group_include.nil?
      Organism.where(group: organism_group_include).pluck(:code).each do |organism_code|
        organisms_codes << organism_code
      end
    end

    # viridans_group_include
    unless viridans_group_include.nil?
      Organism.where(viridans_group: viridans_group_include).pluck(:code).each do |organism_code|
        organisms_codes << organism_code
      end
    end

    # genus_include
    unless genus_include.nil?
      Organism.where(genus: genus_include).pluck(:code).each do |organism_code|
        organisms_codes << organism_code
      end
    end
    

    # genus_exclude 
    unless organism_group_include.nil?
      Organism.where(genus: organism_group_include).pluck(:code).each do |organism_code|
        organisms_codes.delete(organism_code)
      end
    end

    # organism_code_include
    unless organism_code_include.nil?
      organism_code_include.split(",").each do |organism_code|
        organisms_codes << organism_code
      end
    end

    #organism_code_exclude
    unless organism_code_exclude.nil?
      organism_code_exclude.split(",").each do |organism_code|
        organisms_codes.delete(organism_code)
      end
    end

    # level_1_include
    unless level_1_include.nil?
      Organism.where(level_1_class: level_1_include).pluck(:code).each do |organism_code|
        organisms_codes << organism_code
      end
    end

    # level_3_include
    unless level_3_include.nil?
      Organism.where(level_3_class: level_3_include).pluck(:code).each do |organism_code|
        organisms_codes << organism_code
      end
    end

    # level_3_exclude
    unless level_3_exclude.nil?
      Organism.where(level_3_class: level_3_exclude).pluck(:code).each do |organism_code|
        organisms_codes.deleteorganism_code
      end
    end

    self.related_organism_codes_list = organisms_codes.join(", ")
    self.save!
    return related_organism_codes_list
  end

  private

  ## Will return the reaction interpretation based on this s_max and r_min 
  ## values contained within this breakpoint.
  ## KEYS:  S - Susceptible
  ##        I - Intermediate
  ##        R - Resistant
  ##        NS - Not Susceptible
  ##        NI - No Interpretation
  def interpet_reaction_from_breakpoints(mic_result)
    return nil if mic_result.nil?
    return nil if mic_result.mic_edge.nil? || mic_result.mic_value.nil? 
    return nil if s_maximum.nil?

    dillution_index_between_r_and_s = Dilution.index_between(s_maximum, r_minimum)

    # The actual mic_value is lower than OR equal to the measured dillution.
    if mic_result.mic_edge == -1

      if mic_result.mic_value <= s_maximum
        # <=mic_value -- s_max
        return "S"
      else
        if r_minimum
          # NOTE if a -1 edge is equivalent to a logical <= then we can optimize the follwing
          # if statement. Bradley to verify w/ Jason and Johny.
          return "NI"
        else
          ## s_max -- <=mic_value 
          return "S" if Dilution.index_between(s_maximum, mic_result.mic_value) == 1 
          return "NI"
        end
      end

    ## The actual mic_value is higher than the measured dillution.
    elsif mic_result.mic_edge == 1

      if mic_result.mic_value < s_maximum
        ##  mic_value => s_max 
        return "NI"
      elsif mic_result.mic_value == s_maximum
        if r_minimum
          # s_max==mic_value=> -- r_min
          return "R" if Dilution.index_between(r_minimum, mic_result.mic_value) == 1
          return "NS"
        else
          # s_max==mic_value=>
          return "NS"
        end
      else
        if r_minimum
          if mic_result.mic_value >= r_minimum
            # s_max -- r_min = mic_value=>
            return "R"
          else 
            # s_max -- mic_value=> -- r_min
            return "R" if Dilution.index_between(r_minimum, mic_result.mic_value) == 1
            return "NS"
          end
        end
      end

    else
      # Defualt logic holds when the mic_edge value == 0
      if mic_result.mic_value <= s_maximum
        # mic_value -- s_max
        return "S"
      else
        if r_minimum
          if mic_result.mic_value < r_minimum
            # s_max -- mic_value -- r_min
            return "I"
          else
            # s_max -- r_min -- mic_value
            return "R"
          end
        else
          # s_max -- mic_value
          return "NS"
        end
      end
    end
  end

  def interpret_reaction(mic_result, surrogate_drug_reaction_interpretations)
    return nil if mic_result.nil?

    results = Hash.new

    # Use the breakpoints contained within this breakpoint
    results[:interpretation] = interpet_reaction_from_breakpoints(mic_result)

    # If we have surrogate drug reaction interpretations, we need to process additional information
    unless surrogate_drug_reaction_interpretations.nil?

      # We loop through each surrogate drug reaction interpretation
      surrogate_drug_reaction_interpretations.each do |surrogate_drug, surrogate_drug_interpretation|

        # Apply the r_if_surrogate_is logic to the interpretation
        unless r_if_surrogate_is.nil?
          results[:interpretation] = "R" if r_if_surrogate_is.split(",").include?(surrogate_drug_interpretation)
        end

        # Apply the ni_if_surrogate_is logic to the interpretation
        unless ni_if_surrogate_is.nil?
          results[:interpretation] = "NI" if ni_if_surrogate_is.split(",").include?(surrogate_drug_interpretation)
        end

      end # end the loop through each surrogate drug reaction interpretation
    end

    # If we still have not found a reaction interpretation and we have surrogate drug reaction 
    # interpretations,then we need to pick the drug reaction in order.
    if results[:interpretation].nil? && !surrogate_drug_reaction_interpretations.nil?
      results[:used_surrogate_drug_ordinal] = 0
      results[:used_surrogate_rule_type] = "no_base_drug_breakpoints"

      surrogate_drug_reaction_interpretations.each do |surrogate_drug, surrogate_drug_interpretation|

        # This logic loads the surrogate_drug_interpretation that has the highest resistance.
        # "R" <= "I" <= "S"
        if surrogate_drug_interpretation == "S" && 
          (results[:interpretation] != "I" || results[:interpretation] != "R")
          results[:interpretation] = surrogate_drug_interpretation
          results[:used_surrogate_drug_id] = surrogate_drug.id
        elsif surrogate_drug_interpretation == "I" && intepretation[:interpretation] != "R"
          results[:interpretation] = surrogate_drug_interpretation
          results[:used_surrogate_drug_id] = surrogate_drug.id
        elsif surrogate_drug_interpretation == "R"
          results[:interpretation] = surrogate_drug_interpretation
          results[:used_surrogate_drug_id] = surrogate_drug.id
        end

      end
    end

    # Return the result
    return results 
  end

  # !!!Important!!! Surrogate drugs will never have a surrogate themselves. 
  # Therefore we pull out the surrogate interpretation to avoid infite recursive loops.
  def interpret_surrogate_drug_reactions(isolate)
    return nil if isolate.nil?

    intepretation = []

    # For each surrogate drug, 
    surrogate_drugs.each do |surrogate_drug|

      # find a the mic_result for that drug and the input isolate. 
      mic_result = MicResult.where(drug_id: surrogate_drug.id, isolate_id: mic_result.isolate_id).first

      # If we found a mic_result, find the breakpoint we should use for comparision.
      # TODO: Rework determine breakpoint logic so we don't just use the first breakpoint found. 
      breakpoint = ClsiBreakpoint.determine_breakpoint(isolate, surrogate_drug).first unless mic_result.nil?

      # Load each of the surrogate drug reaction interpretations into a hash array with the drug.id 
      # as the key to that value.
      surrogate_drug_intepretation = Hash.new
      surrogate_drug_intepretation[surrogate_drug] = breakpoint.interpret_reaction(mic_result, nil)

    end

    return intepretation
  end

  def determine_eligible_interpretations
    return nil if s_maximum.nil? && r_minimum.nil?

    # If s_max or r_min exists, then s_max must exist
    if r_minimum 
      # Only S & R are elgible if there are zero dilutions between 
      # s_max and r_min
      return "S R" if Dilution.index_between(s_maximum, r_minimum) == 1
      return "S I R"
    else
      return "S NS"
    end
  end
end
