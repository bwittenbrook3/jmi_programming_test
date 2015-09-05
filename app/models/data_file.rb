class DataFile < ActiveRecord::Base

  def self.import(file)
    xlsx = Roo::Spreadsheet.open(file)

    # Import organisms
    Organism.delete_all
    data =  xlsx.sheet('organisms').parse(  code: 'organism_code',
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
                                            level_4_class: 'level_4_class'    ) 
    data.shift
    organisms = []
    data.each do |row|
      organisms << Organism.new(row)
    end
    Organism.import organisms


    # Import isolates
    Isolate.delete_all
    data = xlsx.sheet('isolates').parse(    id: 'isolate_id', 
                                            collection_no: 'collection_no',
                                            site_id: 'site_id',
                                            study_year: 'study_year',
                                            bank_no: 'bank_no',
                                            organism_code: 'organism_code'  )
    data.shift # remove the header row
    isolates = []
    data.each do |row|
      isolates << Isolate.new(row)
    end
    Isolate.import isolates


    # Import mic_results
    MicResult.delete_all
    data = xlsx.sheet('mic_results').parse( isolate_id: 'isolate_id',
                                            drug_id: 'drug_id',
                                            mic_value: 'mic_value', 
                                            mic_edge: 'mic_edge'            ) 
    
    data.shift # Remove the header row
    mic_results = []
    data.each do |row|
      mic_results << MicResult.new(row)
    end
    MicResult.import mic_results
    

    # Import drugs
    Drug.delete_all
    data = xlsx.sheet('drugs').parse(       id: 'drug_id',
                                            name: 'drug_name',
                                            description: 'drug_description'   )
    data.shift
    drugs = []
    data.each do |row|
      drugs << Drug.new(row)
    end 
    Drug.import drugs

    # Import CLSI Breakpoints
    ClsiBreakpoint.delete_all
    data = xlsx.sheet('clsi_2015_breakpoints').parse(   drug_name: 'drug',
                                                        s_maximum: 's_maximum',
                                                        r_minimum: 'r_minimum',
                                                        r_if_surrogate_is: 'r_if_surrogate_is',
                                                        ni_if_surrogate_is: 'ni_if_surrogate_is',
                                                        r_if_blt_is: 'r_if_blt_is',
                                                        delivery_mechanism: 'delivery_mechanism',
                                                        infection_type: 'infection_type',
                                                        footnote: 'footnote',
                                                        master_group_include: 'master_group_include',
                                                        viridans_group_include: 'viridans_group_include',
                                                        genus_include: 'genus_include',
                                                        genus_exclude: 'genus_exclude',
                                                        gram_include: 'gram_include',
                                                        level_1_include: 'level_1_include',
                                                        level_3_include: 'level_3_include',
                                                        level_3_exclude: 'level_3_exclude'  )
    data.shift
    clsi_breakpoints = []
    data.each do |row|
      row[:drug_id] = Drug.find_or_create_by(name: row[:drug_name]).id
      row.delete(:drug_name)
      clsi_breakpoints <<  ClsiBreakpoint.new(row)
    end
    ClsiBreakpoint.import clsi_breakpoints

  end

end
