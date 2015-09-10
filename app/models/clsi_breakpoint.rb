class ClsiBreakpoint < ActiveRecord::Base
  has_one :isolate_drug_breakpoint
  belongs_to :drug

  has_many :surrogate_drug_assignments
  has_many :surrogate_drugs, through: :surrogate_drug_assignments

  after_create :identify_related_organism_codes

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
    results[:used_surrogate_drug_id] = reaction[:used_surrogate_drug_id]
    results[:used_surrogate_drug_ordinal] = reaction[:used_surrogate_drug_ordinal]
    results[:used_surrogate_rule_type] = reaction[:used_surrogate_rule_type]

    return results
  end

  def self.determine_breakpoint(isolate, drug)
    return nil if isolate.nil? || drug.nil?

    # Seach for all 'unique' breakpoints for the organism - drug combination 
    breakpoints = []
    OrganismDrugBreakpoint.where(organism_id: isolate.organism.id, drug_id: drug.id).each do |organism_drug_breakpoint|
      breakpoints << organism_drug_breakpoint.clsi_breakpoint
    end

    # If we found matching breakpoints then return those
    return breakpoints if breakpoints.length > 0
    return nil
  end

  def interpret_reaction(mic_result, surrogate_drug_reaction_interpretations)
    return nil if mic_result.nil?

    results = Hash.new

    # Use the breakpoints contained within this breakpoint
    results[:interpretation] = interpet_reaction_from_breakpoints(mic_result)

    # If we have surrogate drug reaction interpretations, we need to process additional information
    unless surrogate_drug_reaction_interpretations.nil?

      # We loop through each surrogate drug reaction interpretation
      surrogate_drug_reaction_interpretations.each do |surrogate_drug, surrogate_drug_results|
        surrogate_drug_results.each do |surrogate_drug_result|

          # Apply the r_if_surrogate_is logic to the interpretation
          unless r_if_surrogate_is.nil? 
            results[:interpretation] = "R" if r_if_surrogate_is.split(",").include?(surrogate_drug_result[:interpretation])
          end

          # Apply the ni_if_surrogate_is logic to the interpretation
          unless ni_if_surrogate_is.nil?
            results[:interpretation] = "NI" if ni_if_surrogate_is.split(",").include?(surrogate_drug_result[:interpretation])
          end

        end

      end # end the loop through each surrogate drug reaction interpretation
    end

    # If we still have not found a reaction interpretation and we have surrogate drug reaction 
    # interpretations,then we need to pick the drug reaction in order.
    if results[:interpretation].nil? && !surrogate_drug_reaction_interpretations.nil?
      results[:used_surrogate_drug_ordinal] = 0
      results[:used_surrogate_rule_type] = "no_base_drug_breakpoints"

      surrogate_drug_reaction_interpretations.each do |surrogate_drug, surrogate_drug_results|

        # interpret the results for surrogate_drug 
        surrogate_drug_results.each do |surrogate_drug_result|

          # Use the surrogate_drug_interpretation that has the FIRST found VALID interpretation
          if surrogate_drug_result
            results[:interpretation] = surrogate_drug_result[:interpretation]
            results[:used_surrogate_drug_id] = surrogate_drug.id
            break # break out of the surrogate_drug_results.each loop
          end
        end

        # If we found a valid interpretation the we don't need to look at any more of the 
        # surrogate_drug_reaction_interpretations.
        break if results[:interpretation].present?
      end
    end

    # Return the result
    return results 
  end

  private

  def identify_related_organism_codes
    #return related_organism_codes_list unless related_organism_codes_list.nil?
    
    # Higher priority is a stronger match
    priority_based_organism_codes = Hash.new
    (1..7).each do |i|
      priority_based_organism_codes[i] = []
    end

    # master_group_include
    unless master_group_include.nil?
      Organism.where(master_group: master_group_include).pluck(:code).each do |organism_code|
        priority_based_organism_codes[1] << organism_code
      end
    end

    # organism_group_include
    unless organism_group_include.nil?
      Organism.where(group: organism_group_include).pluck(:code).each do |organism_code|
        priority_based_organism_codes[2] << organism_code
      end
    end

    # viridans_group_include
    unless viridans_group_include.nil?
      Organism.where(viridans_group: viridans_group_include).pluck(:code).each do |organism_code|
        priority_based_organism_codes[3] << organism_code
      end
    end

    # genus_include
    unless genus_include.nil?
      Organism.where(genus: genus_include).pluck(:code).each do |organism_code|
        priority_based_organism_codes[4] << organism_code
      end
    end
    
    # genus_exclude 
    unless genus_exclude.nil?
      Organism.where(genus: genus_exclude).pluck(:code).each do |organism_code|
        (1..7).each do |i|
          priority_based_organism_codes[i].delete(organism_code)
        end
      end
    end

    # organism_code_include
    unless organism_code_include.nil?
      organism_code_include.split(",").each do |organism_code|
        priority_based_organism_codes[5] << organism_code
      end
    end

    #organism_code_exclude
    unless organism_code_exclude.nil?
      organism_code_exclude.split(",").each do |organism_code|
        (1..7).each do |i|
          priority_based_organism_codes[i].delete(organism_code)
        end
      end
    end

    # level_1_include
    unless level_1_include.nil?
      Organism.where(level_1_class: level_1_include).pluck(:code).each do |organism_code|
         priority_based_organism_codes[6] << organism_code
      end
    end

    # level_3_include
    unless level_3_include.nil?
      Organism.where(level_3_class: level_3_include).pluck(:code).each do |organism_code|
         priority_based_organism_codes[7] << organism_code
      end
    end

    # level_3_exclude
    unless level_3_exclude.nil?
      Organism.where(level_3_class: level_3_exclude).pluck(:code).each do |organism_code|
        (1..7).each do |i|
          priority_based_organism_codes[i].delete(organism_code)
        end
      end
    end

    #self.related_organism_codes_list.values = organisms_codes.join(", ")
    #self.save!

    create_organism_drug_breakpoints_for(priority_based_organism_codes)
  end

  def create_organism_drug_breakpoints_for(priority_based_organism_codes)

    priority_based_organism_codes.each do |priority, organism_codes|
      organism_codes.each do |organism_code|
        organism = Organism.where(code: organism_code).first_or_create ## <== Not sure about the or_create here

        match_found = false
        OrganismDrugBreakpoint.where(organism_id: organism.id, drug_id: drug.id).each do |organism_drug_breakpoint|
          breakpoint = organism_drug_breakpoint.clsi_breakpoint
          if delivery_mechanism ==  breakpoint.delivery_mechanism &&
            infection_type == breakpoint.infection_type

            if organism_drug_breakpoint.priority < priority
              # Update the breakpoint matching information
              organism_drug_breakpoint.priority = priority
              organism_drug_breakpoint.clsi_breakpoint_id = id 
              organism_drug_breakpoint.save!
            end

            match_found = true
          end
        end

        unless match_found
          OrganismDrugBreakpoint.create(  organism_id: organism.id, 
                                          drug_id: drug.id,
                                          clsi_breakpoint_id: id,
                                          priority: priority         )
        end
      end
    end
  end




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


  # !!!Important!!! Surrogate drugs will never have a surrogate themselves. 
  # Therefore we pull out the surrogate interpretation to avoid infite recursive loops.
  def interpret_surrogate_drug_reactions(isolate)
    return nil if isolate.nil?

    interpretation = Hash.new

    # For each surrogate drug, 
    surrogate_drugs.each do |surrogate_drug|

      # Note: Only one mic_result could exists for any drug - isolate combination
      mic_result = MicResult.where(drug_id: surrogate_drug.id, isolate_id: isolate.id).first

      # If we found a mic_result, find the breakpoint we should use for comparision.
      if mic_result
        breakpoints = ClsiBreakpoint.determine_breakpoint(isolate, surrogate_drug) || []
        interpretation[surrogate_drug] = [] if breakpoints.length > 0
        breakpoints.each do |breakpoint|
          # Load each of the surrogate drug reaction interpretations into a hash array with the drug.id 
          # as the key to that value.
          interpretation[surrogate_drug] << breakpoint.interpret_reaction(mic_result, nil)
        end
      end
    end

    return interpretation if interpretation.size > 0
    return nil
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
