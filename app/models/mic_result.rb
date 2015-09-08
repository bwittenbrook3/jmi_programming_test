class MicResult < ActiveRecord::Base
  belongs_to :drug
  belongs_to :isolate

  DILUTION_VALUES = [ 0.00012, 
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
                      1, 
                      2, 
                      4, 
                      8, 
                      16, 
                      32, 
                      64, 
                      128, 
                      256, 
                      512, 
                      1024]
                      
end
