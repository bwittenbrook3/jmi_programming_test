class Drug < ActiveRecord::Base
  has_many :clsi_breakpoints
end
