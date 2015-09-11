class MicResultValidator < ActiveModel::Validator

  def validate(record)
    validation_errors_of(record).each do |field, error|
      record.errors[field.to_sym] << error
    end
  end

  private 

  VALID_MIC_EDGES = [-1, 0, 1]

  def validation_errors_of(record)
    error_hash = Hash.new

    error_hash["mic_value"] = "Not a valid dilution" unless Dilution.is_valid?(record.mic_value)
    error_hash["mic_edge"] = "Not a valid mic edge" unless VALID_MIC_EDGES.include?(record.mic_edge)

    return error_hash
  end

end
