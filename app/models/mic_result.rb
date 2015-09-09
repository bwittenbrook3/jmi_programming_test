class MicResult < ActiveRecord::Base
  belongs_to :drug
  belongs_to :isolate
                      
end
