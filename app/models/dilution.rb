class Dilution
  include ActiveModel::Model

  POSSIBLE_VALUES = [ 0.00012, 
                      0.00025, 
                      0.0005, 
                      0.001, 
                      0.002, 
                      0.004, 
                      0.008, 
                      0.015, 
                      0.03, 
                      0.06, 
                      0.12, 
                      0.25, 
                      0.5, 
                      1.0, 
                      2.0, 
                      4.0, 
                      8.0, 
                      16.0, 
                      32.0, 
                      64.0, 
                      128.0, 
                      256.0, 
                      512.0, 
                      1024.0]
  
    POSSIBLE_VALUES_HASH ||= Hash[POSSIBLE_VALUES.map.with_index.to_a]

  def self.index_between(dilution_a, dilution_b)
    return nil if dilution_a.nil? || dilution_b.nil?

    dilution_index_of_a = Dilution.index_of(dilution_a)
    dilution_index_of_b = Dilution.index_of(dilution_b)

    return nil if dilution_index_of_a.nil? || dilution_index_of_b.nil?

    return (dilution_index_of_a - dilution_index_of_b).abs
  end

  def self.index_of(dilution)
    dilution = dilution.to_f if dilution.instance_of? BigDecimal
    return POSSIBLE_VALUES_HASH[dilution]
  end
end