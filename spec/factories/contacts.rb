FactoryGirl.define do
  factory :contact, :class => Zuora::Objects::Contact do
    first_name "Example"
    sequence(:last_name){|n| "User #{n}" }
    city "Seattle"
    state "WA"
    postal_code "98101"
    country "USA"
  end
end
