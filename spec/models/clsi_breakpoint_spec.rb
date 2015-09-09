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
  end

end
