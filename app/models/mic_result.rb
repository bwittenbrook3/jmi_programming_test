class MicResult < ActiveRecord::Base
  belongs_to :drug
  belongs_to :isolate
   
  validates_presence_of :isolate_id,
                        :drug_id,
                        :mic_value,
                        :mic_edge
                        
  validates_with MicResultValidator
end
