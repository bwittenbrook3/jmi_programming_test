class ClsiBreakpoint < ActiveRecord::Base
  belongs_to :drug
  has_many :surrogate_drug_assignments
  has_many :surrogate_drugs, through: :surrogate_drug_assignments

  after_create :related_organism_codes

  def reaction(mic_result)
    reaction = ""
    eligible_interpretations = "NULL"
    used_surrogate_drug_id = "NULL"
    used_surrogate_drug_ordinal = "NULL"
    used_surrogate_rule_type = "NULL"

    if mic_result.nil?
      return reaction, eligible_interpretations, used_surrogate_drug_id, used_surrogate_drug_ordinal, used_surrogate_rule_type
    end

    surrogate_drugs_reactions = []
    surrogate_drugs_elgible_values = ""
    surrogate_drugs.each do |surrogate_drug|
      mr = MicResult.where(drug_id: surrogate_drug.id, isolate_id: mic_result.isolate_id).first
      unless mr.nil?
        ClsiBreakpoint.determine_breakpoint(mr.isolate_id, surrogate_drug.id).each do |breakpoint|
          unless breakpoint.nil?
            used_surrogate_drug_id = surrogate_drug.id
            surrogate_reaction = breakpoint.reaction(mr)
            surrogate_drugs_reactions << surrogate_reaction[0]
            surrogate_drugs_elgible_values = surrogate_reaction[1]
          end
        end
      end
    end

    # Identify elgible interpretations
    if s_maximum.nil?
      if r_minimum.nil?
        eligible_interpretations = ""
      end
    else
      if r_minimum.nil?
        eligible_interpretations = "S NS"
      else
        if (r_minimum / 2.0) <= s_maximum
          eligible_interpretations = "S R"
        else
          eligible_interpretations = "S I R"
        end
      end
    end

    reaction = ""
    if is_susptable?(mic_result)
      reaction = "S"
    elsif is_resistant?(mic_result)
      reaction = "R"
    elsif !s_maximum.nil? && !r_minimum.nil?
      reaction = "I"
    end

    if reaction == "" && surrogate_drugs_reactions.size > 0
      eligible_interpretations = surrogate_drugs_elgible_values
      used_surrogate_drug_ordinal = 0
      used_surrogate_rule_type = "no_base_drug_breakpoints"
      reaction = "S" if surrogate_drugs_reactions.include?("S")
      reaction = "I" if surrogate_drugs_reactions.include?("I")
      reaction = "R" if surrogate_drugs_reactions.include?("R")
    end

    surrogate_drugs_reactions.each do |surrogate_drug_reaction|
      unless r_if_surrogate_is.nil?
        reaction = "R" if r_if_surrogate_is.split(",").include?(surrogate_drug_reaction)
      end

      unless ni_if_surrogate_is.nil?
        reaction = "" if ni_if_surrogate_is.split(",").include?(surrogate_drug_reaction)
      end
    end

    return reaction, eligible_interpretations, used_surrogate_drug_id, used_surrogate_drug_ordinal, used_surrogate_rule_type 
  end

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

  def related_mic_results
    return MicResult.where(drug_id: self.drug.id, isolate_id: related_isoloate_ids)
  end

  def related_isoloate_ids
    return Isolate.where(organism_code: related_organism_codes).pluck(:id)
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
  def is_susptable?(mic_result)
    return false if self.s_maximum.nil?

    return mic_result.mic_edge <= 0 && mic_result.mic_value <= self.s_maximum
  end

  def is_resistant?(mic_result)
    return false if self.r_minimum.nil?

    if mic_result.mic_edge <= 0 
      return mic_result.mic_value >= self.r_minimum
    else
      return mic_result.mic_value >= (self.r_minimum / 2.0)
    end
  end
end
