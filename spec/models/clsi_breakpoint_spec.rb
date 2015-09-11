require 'rails_helper'

RSpec.describe ClsiBreakpoint, type: :model do
  ## Note: #menthod_name refers to an instance method
  ##       .method_name reters to a class method


  describe "#analyze" do

    # It should return nil if no mic_value is provided
    context "(nil)" do 
      let(:breakpoint) { FactoryGirl.create :standard_breakpoint }
      subject { breakpoint.analyze(nil) }
      it { is_expected.to be_nil }
    end

    # It should return appropriate values if r_min is nil in the breakpoint
    context "breakpoints: {s_min: 1.0, r_min: nil}" do
      let(:breakpoint) {FactoryGirl.create :no_r_minimum_breakpoint}

      context "mic_result: {mic_value: 0.5}" do
        let(:mic_value) { FactoryGirl.create :mic_result, mic_value: 0.5 }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S NS") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 4.0}" do
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 4.0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S NS") } 
        it { is_expected.to include(:interpretation => "NS") }
      end
    end

    # Fully testing a breakpoint with zero dillutions between s_max and r_min
    context "breakpoints: {s_max: 2.0, r_min: 4.0}" do 
      let(:breakpoint) {FactoryGirl.create :zero_dilution_breakpoint}

      ## MIC value of 1.0
      context "mic_result: {mic_value: 1.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 1.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S R") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 1.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 1.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S R") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 1.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 1.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S R") } 
        it { is_expected.to include(:interpretation => "NI") }
      end

      ## MIC value of 2.0
      context "mic_result: {mic_value: 2.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 2.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S R") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 2.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 2.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S R") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 2.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 2.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S R") } 
        it { is_expected.to include(:interpretation => "R") }
      end

      ## MIC value of 4.0
      context "mic_result: {mic_value: 4.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 4.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S R") } 
        it { is_expected.to include(:interpretation => "NI") }
      end

      context "mic_result: {mic_value: 4.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 4.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S R") } 
        it { is_expected.to include(:interpretation => "R") }
      end

      context "mic_result: {mic_value: 4.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 4.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S R") } 
        it { is_expected.to include(:interpretation => "R") }
      end

      ## MIC value of 8.0
      context "mic_result: {mic_value: 8.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 8.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S R") } 
        it { is_expected.to include(:interpretation => "NI") }
      end

      context "mic_result: {mic_value: 8.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 8.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S R") } 
        it { is_expected.to include(:interpretation => "R") }
      end

      context "mic_result: {mic_value: 8.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 8.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S R") } 
        it { is_expected.to include(:interpretation => "R") }
      end
    end

    # Fully testing a breakpoint with one dillution between s_max and r_min
    context "breakpoints: {s_max: 2.0, r_min: 8.0}" do 
      let(:breakpoint) {FactoryGirl.create :one_dilution_breakpoint}

      ## MIC value of 1.0
      context "mic_result: {mic_value: 1.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 1.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 1.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 1.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 1.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 1.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "NI") }
      end

      ## MIC value of 2.0
      context "mic_result: {mic_value: 2.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 2.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 2.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 2.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 2.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 2.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "NS") }
      end

      ## MIC value of 4.0
      context "mic_result: {mic_value: 4.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 4.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "NI") }
      end

      context "mic_result: {mic_value: 4.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 4.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "I") }
      end

      context "mic_result: {mic_value: 4.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 4.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "R") }
      end

      ## MIC value of 8.0
      context "mic_result: {mic_value: 8.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 8.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "NI") }
      end

      context "mic_result: {mic_value: 8.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 8.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "R") }
      end

      context "mic_result: {mic_value: 8.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 8.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "R") }
      end
    end

    # Fully testing a breakpoint with two dillutions between s_max and r_min
    context "breakpoints: {s_max: 2.0, r_min: 16.0}" do 
      let(:breakpoint) {FactoryGirl.create :two_dilution_breakpoint}

      ## MIC value of 1.0
      context "mic_result: {mic_value: 1.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 1.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 1.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 1.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 1.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 1.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "NI") }
      end

      ## MIC value of 2.0
      context "mic_result: {mic_value: 2.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 2.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 2.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 2.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "S") }
      end

      context "mic_result: {mic_value: 2.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 2.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "NS") }
      end

      ## MIC value of 4.0
      context "mic_result: {mic_value: 4.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 4.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "NI") }
      end

      context "mic_result: {mic_value: 4.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 4.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "I") }
      end

      context "mic_result: {mic_value: 4.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 4.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "NS") }
      end

      ## MIC value of 8.0
      context "mic_result: {mic_value: 8.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 8.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "NI") }
      end

      context "mic_result: {mic_value: 8.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 8.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "I") }
      end

      context "mic_result: {mic_value: 8.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 8.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "R") }
      end

      ## MIC value of 16.0
      context "mic_result: {mic_value: 16.0, mic_edge: -1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 16.0, mic_edge: -1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "NI") }
      end

      context "mic_result: {mic_value: 16.0, mic_edge: 0}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 16.0, mic_edge: 0) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "R") }
      end

      context "mic_result: {mic_value: 16.0, mic_edge: 1}" do 
        let(:mic_value) { FactoryGirl.create(:mic_result, mic_value: 16.0, mic_edge: 1) }
        subject { breakpoint.analyze(mic_value) }
        it { is_expected.to include(:eligible_interpretations => "S I R") } 
        it { is_expected.to include(:interpretation => "R") }
      end
    end

    context "breakpoint {s_max: nil, r_min: nil}" do 
      let(:breakpoint) { FactoryGirl.create :empty_breakpoint } 
      let(:mic_result) { FactoryGirl.create(:mic_result, mic_value: 1.0, mic_edge: 0) }

      context "surrogate_drugs: {}" do 
        subject { breakpoint.analyze(mic_result) }
        it { is_expected.to include(:interpretation => nil) }
      end
 
      context "breakpoint: {surrogate_drugs: [surrogate_drug]}" do 
        it "should use the surrogate breakpoint results" do 
          organism = FactoryGirl.create(:organism)
          alternate_organism = FactoryGirl.create(:alternate_organism)

          isolate = FactoryGirl.create(:isolate)

          drug = FactoryGirl.create(:surrogate_drug)
          surrogate_drug = FactoryGirl.create(:surrogate_drug)

          breakpoint = FactoryGirl.create(:empty_breakpoint, drug: drug)
          breakpoint.surrogate_drugs << surrogate_drug
          surrogate_breakpoint = FactoryGirl.create(:standard_breakpoint, drug: surrogate_drug)

          mic_result = FactoryGirl.create(:mic_result, drug_id: drug.id, isolate_id: isolate.id)
          surrogate_mic_result = FactoryGirl.create(:mic_result, drug_id: surrogate_drug.id, isolate_id: isolate.id)

          result = breakpoint.analyze(mic_result)
          expect(result).to include(:interpretation => "S")
        end
      end
    end
  end

  describe "#determine_eligible_interpretations" do

    context "{s_max: nil, r_min: nil}" do 
      let(:breakpoint) { FactoryGirl.create :empty_breakpoint }
      subject { breakpoint.send(:determine_eligible_interpretations) }
      it { is_expected.to be_nil }
    end

    context "{s_max: 1.0, r_min: nil}" do
      let(:breakpoint) { FactoryGirl.create :no_r_minimum_breakpoint }
      subject { breakpoint.send(:determine_eligible_interpretations) }
      it { is_expected.to eq("S NS") }
    end

    context "{s_max: 2.0, r_min: 4.0}" do 
      let(:breakpoint) { FactoryGirl.create :zero_dilution_breakpoint }
      subject { breakpoint.send(:determine_eligible_interpretations) }
      it { is_expected.to eq("S R") }
    end

    context "{s_max: 2.0, r_min: 8.0}" do 
      let(:breakpoint) { FactoryGirl.create :one_dilution_breakpoint }
      subject { breakpoint.send(:determine_eligible_interpretations) }
      it { is_expected.to eq("S I R") }
    end
  end

  describe "#interpret_surrogate_drug_reactions" do

    context "(nil)" do 
      let (:breakpoint) { FactoryGirl.create :breakpoint_with_one_surrogate_drug }
      subject { breakpoint.send(:interpret_surrogate_drug_reactions, nil) }
      it { is_expected.to be_nil }
    end

    context "(isolate)" do 
      let (:isolate) { FactoryGirl.create :isolate }

      context "breakpoint.surrogate drugs: nil" do 
        let (:breakpoint) { FactoryGirl.create :standard_breakpoint }
        specify { expect(breakpoint.surrogate_drugs.count).to eq(0) }
        subject { breakpoint.send(:interpret_surrogate_drug_reactions, isolate) }
        it { is_expected.to be_nil }
      end

      context "breakpoint.surrogate drugs: {surrogate_drug}" do 

        it "should interpret the surrogate drug reactions correctly" do 
          organism = FactoryGirl.create(:organism)
          alternate_organism = FactoryGirl.create(:alternate_organism)
          breakpoint = FactoryGirl.create(:breakpoint_with_one_surrogate_drug)
          surrogate_drug = breakpoint.surrogate_drugs.first
          mic_result = FactoryGirl.create(:mic_result, drug_id: surrogate_drug.id, isolate_id: isolate.id)

          # s_max: 1, r_min: 4, mic_value: 1, mic_edge: 0
          interpret_surrogate_drug_reactions = breakpoint.send(:interpret_surrogate_drug_reactions, isolate)
          expect(interpret_surrogate_drug_reactions[surrogate_drug]).to include(:interpretation => "S")
        end
      end
    end
  end

  describe "#create_organism_drug_breakpoints_for" do 

    context "(nil)" do 
      let(:breakpoint) {FactoryGirl.create :standard_breakpoint}
      # let(:priority_based_organism_codes) { { 1 => "AB"} }
      #subject { breakpoint.create_organism_drug_breakpoints_for(nil) }
      #it { is_expected.to be_nil }

      it "should not add any new organism_drug_breakpoints" do 
        expect(OrganismDrugBreakpoint.all.count).to eq(0)
        breakpoint.send(:create_organism_drug_breakpoints_for, nil)
        expect(OrganismDrugBreakpoint.all.count).to eq(0)
      end
    end

    context "( {1 => ['AB']} )" do 
      let(:breakpoint) {FactoryGirl.create :standard_breakpoint}
      let(:priority_based_organism_codes) { { 1 => ["AB"]} }

      it "should add an organism with code 'AB'" do 
        expect(Organism.where(code: "AB").count).to eq(0)
        breakpoint.send(:create_organism_drug_breakpoints_for, priority_based_organism_codes)
        expect(Organism.where(code: "AB").count).to eq(1)
      end

      context "and 'AB' already exists" do 

        it "should not add a NEW organism with code 'AB'" do 
          Organism.create(code: "AB")
          expect(Organism.where(code: "AB").count).to eq(1)
          breakpoint.send(:create_organism_drug_breakpoints_for, priority_based_organism_codes)
          expect(Organism.where(code: "AB").count).to eq(1)
        end
      end

      context "a breakpoint for the drug/organism combination already exists" do 
        it "should not add a new breakpoint unless the priority match is higher" do 
          breakpoint.send(:create_organism_drug_breakpoints_for, priority_based_organism_codes)
          expect(OrganismDrugBreakpoint.all.count).to eq(1)
          breakpoint.send(:create_organism_drug_breakpoints_for, { 3 => ["AB"] })
          expect(OrganismDrugBreakpoint.all.count).to eq(1)
          organism_drug_breakpoint = OrganismDrugBreakpoint.all.first
          expect(organism_drug_breakpoint.priority).to eq(3)
          expect(organism_drug_breakpoint.organism.code).to eq("AB")
        end
      
      end
    end

    context "( {1 => ['AB', 'BC']} )" do 
      let(:breakpoint) {FactoryGirl.create :standard_breakpoint}
      let(:priority_based_organism_codes) { { 1 => ["AB", "BC"]} }

      it "should add an organism with code 'AB' and one with 'BC'" do 
        expect(Organism.all.count).to eq(0)
        breakpoint.send(:create_organism_drug_breakpoints_for, priority_based_organism_codes)
        expect(Organism.all.count).to eq(2)
      end
    end

  end

end
