FactoryGirl.define do
  factory :subscription, :class => Zuora::Objects::Subscription do
    contract_effective_date DateTime.now
    sequence(:name){|n| "Example Subscription #{n}"}
    term_start_date DateTime.now
    initial_term 12
    renewal_term 12
  end
end
