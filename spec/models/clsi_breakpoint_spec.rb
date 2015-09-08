require 'rails_helper'

RSpec.describe ClsiBreakpoint, type: :model do
  before(:each) do
  end

  ## Testing simple breakpoint cases
  ## - s_maximum: 1.0
  ## - r_minimum: 4.0

  it "should not interpret a reaction without a mic_result" do
    breakpoint = create(:standard_breakpoint)
    expect(breakpoint.analyze(nil)).to eq(nil)
  end

  it "should be able to correctly interpret 'susceptible'" do 
    breakpoint = create(:standard_breakpoint)
    mic_result = create(:mic_result, mic_value: 0.5)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S I R")
    expect(results[:interpretation]).to eq("S")
  end

  it "should be able to correctly interpret 'Intermediate'" do 
    breakpoint = create(:standard_breakpoint)
    mic_result = create(:mic_result, mic_value: 2.0)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S I R")
    expect(results[:interpretation]).to eq("I")
  end

  it "should be able to correctly interpret 'resistant'" do 
    breakpoint = create(:standard_breakpoint)
    mic_result = create(:mic_result, mic_value: 6.0)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S I R")
    expect(results[:interpretation]).to eq("R")
  end

  ## Testing breakpoint without a r_minimum
  ## - s_maximum: 1.0

  it "should be able to correctly interpret 'susceptible'" do
    breakpoint = create(:no_r_minimum_breakpoint)
    mic_result = create(:mic_result, mic_value: 0.5)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S NS")
    expect(results[:interpretation]).to eq("S")
  end

  it "should be able to correctly interpret 'non-susceptible'" do
    breakpoint = create(:no_r_minimum_breakpoint)
    mic_result = create(:mic_result, mic_value: 4.0)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S NS")
    expect(results[:interpretation]).to eq("NS")
  end

  ## Testing case where there's zero dilutions between s_max and r_min
  ## - s_maximum: 2.0
  ## - r_minimum: 4.0

  it "should be able to correctly interpret 'susceptible'" do 
    breakpoint = create(:zero_dilution_breakpoint)
    mic_result = create(:mic_result, mic_value: 1.0, mic_edge: -1)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S R")
    expect(results[:interpretation]).to eq("S")
  end

  it "should be able to correctly interpret 'susceptible'" do 
    breakpoint = create(:zero_dilution_breakpoint)
    mic_result = create(:mic_result, mic_value: 1.0, mic_edge: 0)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S R")
    expect(results[:interpretation]).to eq("S")
  end

  it "should be able to correctly interpret 'no interp'" do 
    breakpoint = create(:zero_dilution_breakpoint)
    mic_result = create(:mic_result, mic_value: 1.0, mic_edge: 1)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S R")
    expect(results[:interpretation]).to eq("NI")
  end

  it "should be able to correctly interpret 'susceptible'" do 
    breakpoint = create(:zero_dilution_breakpoint)
    mic_result = create(:mic_result, mic_value: 2.0, mic_edge: -1)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S R")
    expect(results[:interpretation]).to eq("S")
  end

  it "should be able to correctly interpret 'susceptible'" do 
    breakpoint = create(:zero_dilution_breakpoint)
    mic_result = create(:mic_result, mic_value: 2.0, mic_edge: 0)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S R")
    expect(results[:interpretation]).to eq("S")
  end

  it "should be able to correctly interpret 'resistant'" do 
    breakpoint = create(:zero_dilution_breakpoint)
    mic_result = create(:mic_result, mic_value: 2.0, mic_edge: 1)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S R")
    expect(results[:interpretation]).to eq("R")
  end

  it "should be able to correctly interpret 'no interp'" do 
    breakpoint = create(:zero_dilution_breakpoint)
    mic_result = create(:mic_result, mic_value: 4.0, mic_edge: -1)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S R")
    expect(results[:interpretation]).to eq("NI")
  end

  it "should be able to correctly interpret 'resistant'" do 
    breakpoint = create(:zero_dilution_breakpoint)
    mic_result = create(:mic_result, mic_value: 4.0, mic_edge: 0)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S R")
    expect(results[:interpretation]).to eq("R")
  end

  it "should be able to correctly interpret 'resistant'" do 
    breakpoint = create(:zero_dilution_breakpoint)
    mic_result = create(:mic_result, mic_value: 4.0, mic_edge: 1)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S R")
    expect(results[:interpretation]).to eq("R")
  end

  it "should be able to correctly interpret 'no interp'" do 
    breakpoint = create(:zero_dilution_breakpoint)
    mic_result = create(:mic_result, mic_value: 8.0, mic_edge: -1)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S R")
    expect(results[:interpretation]).to eq("NI")
  end

  it "should be able to correctly interpret 'resistant'" do 
    breakpoint = create(:zero_dilution_breakpoint)
    mic_result = create(:mic_result, mic_value: 8.0, mic_edge: 0)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S R")
    expect(results[:interpretation]).to eq("R")
  end

  it "should be able to correctly interpret 'resistant'" do 
    breakpoint = create(:zero_dilution_breakpoint)
    mic_result = create(:mic_result, mic_value: 8.0, mic_edge: 1)
    results = breakpoint.analyze(mic_result)
    expect(results[:eligible_interpretations]).to eq("S R")
    expect(results[:interpretation]).to eq("R")
  end

end
