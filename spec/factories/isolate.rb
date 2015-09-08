FactoryGirl.define do
  factory :isolate do 
    
    collection_no 123456
    site_id 123
    study_year { Time.now.year }
    bank_no 123
    organism_code { FactoryGirl.create(:organism).code }

  end
end