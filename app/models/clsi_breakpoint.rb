class ClsiBreakpoint < ActiveRecord::Base
  belongs_to :drug
  has_many :surrogate_drug_assignments
  has_many :surrogate_drugs, through: :surrogate_drug_assignments

  def reaction(mic_result)
    return "" if mic_result.nil?

    surrogate_drugs_reactions = []
    surrogate_drugs.each do |surrogate_drug|
      breakpoint = ClsiBreakpoint.determine_breakpoint(mic_result.isolate.id, surrogate_drug.id).last
      surrogate_drugs_reactions << breakpoint.reaction(mic_result) unless breakpoint.nil?
    end

    out = ""
    if is_susptable?(mic_result)
      out = "S"
    elsif is_resistant?(mic_result)
      out = "R"
    elsif !s_maximum.nil? && !r_minimum.nil?
      out = "I"
    end

    if out == "" && surrogate_drugs_reactions.size > 0
      out = "S" if surrogate_drugs_reactions.include?("S")
      out = "I" if surrogate_drugs_reactions.include?("I")
      out = "R" if surrogate_drugs_reactions.include?("R")
    end

    surrogate_drugs_reactions.each do |surrogate_drug_reaction|
      unless r_if_surrogate_is.nil?
        out = "R" if r_if_surrogate_is.include?(surrogate_drug_reaction)
      end

      unless ni_if_surrogate_is.nil?
        out = "" if ni_if_surrogate_is.include?(surrogate_drug_reaction)
      end
    end

    return out
  end

  def self.determine_breakpoint(isolate_id, drug_id)
    isolate = Isolate.find(isolate_id)
    drug = Drug.find(drug_id)
    mic_results = MicResult.where(isolate_id: isolate_id, drug_id: drug_id)
    breakpoints = []
    drug.clsi_breakpoints.each do |breakpoint|
      if breakpoint.related_organism_codes.include?(isolate.organism_code)
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
    organisms_codes = []

    # master_group_include
    unless master_group_include.nil?
      Organism.where(master_group: master_group_include).pluck(:code).each do |organism_code|
        organisms_codes << organism_code
      end
    end

    # organism_group_include
    unless master_group_include.nil?
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

    return organisms_codes
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
