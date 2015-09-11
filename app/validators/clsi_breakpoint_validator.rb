class ClsiBreakpointValidator < ActiveModel::Validator
  def validate(record)
    validation_errors_of(record).each do |validation_error|
      record.errors[:base] << validation_error
    end
  end

  private 
  def validation_errors_of(record)
    errors = []

    s_max = record.s_maximum
    r_min = record.r_minimum

    # Record Validation
    errors << "Invalid s_maximum dilution" unless valid_dilution?(s_max)
    errors << "Invalid r_minimum dilution" unless valid_dilution?(r_min)
    errors << "Invalid s_maximum/r_minimum combination" unless valid_s_max_r_min_combination?(s_max, r_min)

    return errors
  end

  def valid_s_max_r_min_combination?(s_max, r_min)
    return true if s_max.nil? || r_min.nil?
    return false if !valid_dilution?(s_max) || !valid_dilution?(r_min)

    s_max_dilution_index = Dilution.index_of(s_max)
    r_min_dilution_index = Dilution.index_of(r_min)
    return false unless s_max_dilution_index < r_min_dilution_index

    return true # Otherwise
  end

  def valid_dilution?(dilution)
    return true if dilution.nil?
    return false unless dilution.is_a?(BigDecimal)
    return false if Dilution.index_of(dilution).nil?

    return true # Otherwise
  end
end