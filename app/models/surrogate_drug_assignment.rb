class SurrogateDrugAssignment < ActiveRecord::Base
  belongs_to :surrogate_drug, class_name: "Drug"
  belongs_to :clsi_breakpoint, class_name: "ClsiBreakpoint"
end
