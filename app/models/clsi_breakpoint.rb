class ClsiBreakpoint < ActiveRecord::Base
  belongs_to :drug
  has_many :surrogate_drug_assignments
  has_many :surrogate_drugs, through: :surrogate_drug_assignments

  def self.determine_reaction(isolate_id, drug_id)
    mic_results = MicResult.where(isolate_id: isolate_id, drug_id: drug_id).first
    breakpoint = self.determine_breakpoint(isolate_id, drug_id)

    return "" if breakpoint.nil?
    return "" if breakpoint.surrogate_drugs.count > 0
    return "" if mic_results.nil?

    # Logic reads breakpoint information
    if mic_results.mic_edge != 1 
      if mic_results.mic_value <= breakpoint.s_maximum
        return "S"
      elsif mic_results.mic_value >= breakpoint.r_minimum
        return "R"
      else
        return "I"
      end
    else
      if mic_results.mic_value >= (breakpoint.s_maximum / 2.0)
        return "R"
      else
        return "I"
      end
    end

  end

  def self.determine_breakpoint(isolate_id, drug_id)
    isolate = Isolate.find(isolate_id)
    drug = Drug.find(drug_id)
    mic_results = MicResult.where(isolate_id: isolate_id, drug_id: drug_id)
    drug.clsi_breakpoints.each do |breakpoint|
      if breakpoint.related_organism_codes.include?(isolate.organism_code)
        return breakpoint
      end
    end
    return nil
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
    Organism.where(master_group: self.master_group_include).pluck(:code).each do |organism_code|
      organisms_codes << organism_code
    end

    # organism_group_include
    Organism.where(group: self.organism_group_include).pluck(:code).each do |organism_code|
      organisms_codes << organism_code
    end

    # viridans_group_include
    Organism.where(viridans_group: self.viridans_group_include).pluck(:code).each do |organism_code|
      organisms_codes << organism_code
    end

    # genus_include
    Organism.where(genus: self.genus_include).pluck(:code).each do |organism_code|
      organisms_codes << organism_code
    end

    # genus_exclude 
    Organism.where(genus: self.organism_group_include).pluck(:code).each do |organism_code|
      organisms_codes.delete(organism_code)
    end

    # organism_code_include
    codes = self.organism_code_include || ""
    codes.split(",").each do |organism_code|
      puts organism_code
      organisms_codes << organism_code
    end

    #organism_code_exclude
    codes = self.organism_code_exclude || ""
    codes.split(",").each do |organism_code|
      organisms_codes.delete(organism_code)
    end

    # level_1_include
    Organism.where(level_1_class: self.level_1_include).pluck(:code).each do |organism_code|
      organisms_codes << organism_code
    end

    # level_3_include
    Organism.where(level_3_class: self.level_3_include).pluck(:code).each do |organism_code|
      organisms_codes << organism_code
    end

    # level_3_exclude
    Organism.where(level_3_class: self.level_3_exclude).pluck(:code).each do |organism_code|
      organisms_codes.deleteorganism_code
    end

    return organisms_codes
  end


end
