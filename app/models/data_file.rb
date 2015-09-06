class DataFile < ActiveRecord::Base

  def self.import(file)
    xlsx = Roo::Spreadsheet.open(file.path)

    # Import organisms
    Organism.delete_all
    data =  xlsx.sheet('organisms').parse(*self.organisms_sheet_headers)
    data.shift
    organisms = []
    data.each do |row|
      organisms << Organism.new(row)
    end
    Organism.import organisms


    # Import isolates
    Isolate.delete_all
    data = xlsx.sheet('isolates').parse(*self.isolates_sheet_headers)
    data.shift # Important! - remove the header row
    isolates = []
    data.each do |row|
      isolates << Isolate.new(row)
    end
    Isolate.import isolates


    # Import mic_results
    MicResult.delete_all
    data = xlsx.sheet('mic_results').parse(*self.mic_results_sheet_headers) 
    
    data.shift # Remove the header row
    mic_results = []
    data.each do |row|
      mic_results << MicResult.new(row)
    end
    MicResult.import mic_results
    

    # Import drugs
    Drug.delete_all
    data = xlsx.sheet('drugs').parse(*self.drugs_sheet_headers)
    data.shift
    drugs = []
    data.each do |row|
      drugs << Drug.new(row)
    end 
    Drug.import drugs

    # Import CLSI Breakpoints
    ClsiBreakpoint.delete_all
    SurrogateDrugAssignment.delete_all
    data = xlsx.sheet('clsi_2015_breakpoints').parse(*self.clsi_breakpoints_sheet_headers)
    data.shift
    data.each_with_index do |row, index|
      row[:drug_id] = Drug.find_or_create_by(name: row[:drug_name]).id
      row.delete(:drug_name)
      surrogate_drugs_literal = row[:surrogate_drugs] || ""
      row.delete(:surrogate_drugs)

      row[:rule_row_number] = index + 2 # Plus two for the zero-index and header row

      surrogate_drug_names = String.new(surrogate_drugs_literal).split(",").map(&:strip)

      clsi_breakpoint = ClsiBreakpoint.create(row)

      surrogate_drug_names.each do |surrogate_drug_name|
        clsi_breakpoint.surrogate_drugs << Drug.find_or_create_by(name: surrogate_drug_name)
      end
    end

  end

  private 

  def self.organisms_sheet_headers
    return [    code: 'organism_code',
                name: 'organism_name',
                genus: 'genus',
                species: 'species',
                sub_species: 'sub_species',
                group: 'organism_group',
                master_group: 'master_group',
                viridans_group: 'viridans_group',
                level_1_class: 'level_1_class',
                level_2_class: 'level_2_class',
                level_3_class: 'level_3_class',
                level_4_class: 'level_4_class'      ]
  end 

  def self.isolates_sheet_headers
    return [    id: 'isolate_id', 
                collection_no: 'collection_no',
                site_id: 'site_id',
                study_year: 'study_year',
                bank_no: 'bank_no',
                organism_code: 'organism_code'      ]
  end

  def self.mic_results_sheet_headers
    return [    isolate_id: 'isolate_id',
                drug_id: 'drug_id',
                mic_value: 'mic_value', 
                mic_edge: 'mic_edge'                ]
  end

  def self.drugs_sheet_headers
    return [    id: 'drug_id',
                name: 'drug_name',
                description: 'drug_description'     ]
  end

  def self.clsi_breakpoints_sheet_headers
    return [    drug_name: 'drug',
                s_maximum: 's_maximum',
                r_minimum: 'r_minimum',
                surrogate_drugs: 'surrogate_drugs',
                r_if_surrogate_is: 'r_if_surrogate_is',
                ni_if_surrogate_is: 'ni_if_surrogate_is',
                r_if_blt_is: 'r_if_blt_is',
                delivery_mechanism: 'delivery_mechanism',
                infection_type: 'infection_type',
                footnote: 'footnote',
                master_group_include: 'master_group_include',
                organism_group_include: 'organism_group_include',
                viridans_group_include: 'viridans_group_include',
                genus_include: 'genus_include',
                genus_exclude: 'genus_exclude',
                organism_code_include: 'organism_code_include',
                organism_code_exclude: 'organism_code_exclude',
                gram_include: 'gram_include',
                level_1_include: 'level_1_include',
                level_3_include: 'level_3_include',
                level_3_exclude: 'level_3_exclude'                  ]
  end
end
