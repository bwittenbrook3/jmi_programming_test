class ClsiBreakpoint < ActiveRecord::Base
  belongs_to :drug
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

    reaction_interpretation = interpret_reaction(mic_result, surrogate_drug_reaction_interpretations)
    results[:interpretation] = reaction_interpretation[:reaction]


    return results
  end

  # JASON: mic_results is unused
  # JASON: should pass in Isolate instead of isolate_id ?
  # JASON: should pass in Drug instead of drug_id ?
  # JASON: outer loop calling this method is looping over all mic results
  # JASON: This method returns all breakpoints that apply to the current
  # JASON: isolate's orgcode and current mic result's drug
  # JASON: (may be multiple ones if there are different authorities/
  # JASON: publications/ delivery mechanisms/infection types)
  # JASON: should split breakpoint.related_organism_codes column into
  # JASON: sub table and add database constraint so can only have one
  # JASON: breakpoint rule defined for any given combination of
  # JASON: auth/pub/deliv/infec/orgcode/drug
  def self.determine_breakpoint(isolate_id, drug_id)
    isolate = Isolate.find(isolate_id)
    drug = Drug.find(drug_id)
    mic_results = MicResult.where(isolate_id: isolate_id, drug_id: drug_id)
    breakpoints = []
    drug.clsi_breakpoints.each do |breakpoint|
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

  def reaction_results(mic_result)
    if mic_result.mic_edge == 1
      # TODO replace with DILUTION_VALUES increment
      return "NI" if (mic_result.mic_value * 2.0) <= s_maximum
    elsif mic_result.mic_edge == -1 && !r_minimum.nil?
      # TODO replace with DILUTION_VALUES increment
      if (r_minimum / 2.0) <= s_maximum
        return "NI" if mic_result.mic_value >= r_minimum
      else
        return "NI" if (mic_result.mic_value / 2.0) >= r_minimum
      end
    end

    return "S" if is_susptable?(mic_result)
    return "R" if is_resistant?(mic_result)
    return "I" if !s_maximum.nil? && !r_minimum.nil?
    return "NS" if !s_maximum.nil? && r_minimum.nil?
    return ""
  end

  def interpret_reaction(mic_result, surrogate_drug_reaction_interpretations)
    return nil if mic_result.nil?

    interpretation = Hash.new

    interpretation[:reaction] = reaction_results(mic_result)

    # If we have surrogate drug reaction interpretations, we need to process additional information
    unless surrogate_drug_reaction_interpretations.nil?

      # We loop through each surrogate drug reaction interpretation
      surrogate_drug_reaction_interpretations.each do |surrogate_drug, surrogate_drug_interpretation|

        # Apply the r_if_surrogate_is logic to the interpretation
        unless r_if_surrogate_is.nil?
          interpretation[:reaction] = "R" if r_if_surrogate_is.split(",").include?(surrogate_drug_interpretation)
        end

        # Apply the ni_if_surrogate_is logic to the interpretation
        unless ni_if_surrogate_is.nil?
          interpretation[:reaction] = "NI" if ni_if_surrogate_is.split(",").include?(surrogate_drug_interpretation)
        end

      end # end the loop through each surrogate drug reaction interpretation
    end

    # If we still have not found a reaction interpretation and we have surrogate drug reaction 
    # interpretations,then we need to pick the drug reaction in order.
    if interpretation[:reaction].nil? && !surrogate_drug_reaction_interpretations.nil?
      interpretation[:used_surrogate_drug_ordinal] = 0
      interpretation[:used_surrogate_rule_type] = "no_base_drug_breakpoints"

      surrogate_drug_reaction_interpretations.each do |surrogate_drug, surrogate_drug_interpretation|

        # This logic loads the surrogate_drug_interpretation that has the highest resistance.
        # "R" <= "I" <= "S"
        if surrogate_drug_interpretation == "S" && 
          (intepretation[:reaction] != "I" || intepretation[:reaction] != "R")
          intepretation[:reaction] = surrogate_drug_interpretation
          interpretation[:used_surrogate_drug_id] = surrogate_drug.id
        elsif surrogate_drug_interpretation == "I" && intepretation[:reaction] != "R"
          intepretation[:reaction] = surrogate_drug_interpretation
          interpretation[:used_surrogate_drug_id] = surrogate_drug.id
        elsif surrogate_drug_interpretation == "R"
          intepretation[:reaction] = surrogate_drug_interpretation
          interpretation[:used_surrogate_drug_id] = surrogate_drug.id
        end

      end
    end

    # Return the result
    return interpretation 
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
    if s_maximum.nil?
      if r_minimum.nil?
        eligible_interpretations = ""
      end
    else
      if r_minimum.nil?
        eligible_interpretations = "S NS"
      else
        # JASON: clever, but assumes we only use doubling dilution
        # JASON: ranges which may not be true for some MIC testing
        # JASON: Need to implement concept of "ordinal" to know 
        # JASON: whether there are any valid MIC values that lie 
        # JASON: in between s_maximum and r_minimum
        if (r_minimum / 2.0) <= s_maximum
          eligible_interpretations = "S R"
        else
          eligible_interpretations = "S I R"
        end
      end
    end
  end

  def interpretation_default_params
    interpretations = Hash.new
    interpretations[:reaction] = ""
    interpretations[:eligible_interpretations] ="NULL"
    interpretations[:used_surrogate_drug_id] = "NULL"
    interpretations[:used_surrogate_drug_ordinal] = "NULL"
    interpretations[:used_surrogate_rule_type] = "NULL"

    return interpretations
  end

  def is_susptable?(mic_result)
    # JASON: is self. necessary here since we're an instance method?
    return false if self.s_maximum.nil?

    # JASON: is self. necessary here since we're an instance method?
    return mic_result.mic_edge <= 0 && mic_result.mic_value <= self.s_maximum
  end

  def is_resistant?(mic_result)
    # JASON: is self. necessary here since we're an instance method?
    return false if self.r_minimum.nil?

    # JASON:  <=2 has mic,edge of 2.0, -1
    # JASON:  if r_minimum is 2.0, this will call it resistant
    # JASON:  but should be NI (no interp)
    if mic_result.mic_edge <= 0 
      return mic_result.mic_value >= self.r_minimum
    else
      return mic_result.mic_value >= (self.r_minimum / 2.0)
    end
  end
end
