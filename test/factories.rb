FactoryGirl.define do
  factory :named_entity do
    sequence(:text) { |n| "text_#{ n }" }
    sequence(:lemma) { |n| "text_#{ n }" }
    ne_class 'NP00G00'
  end

  factory :person do
    sequence(:name) { |n| "name_#{ n }" }
  end
end
