# encoding: utf-8

FactoryGirl.define do
  factory :named_entity do
    sequence(:text) { |n| "text_#{ n }" }
    sequence(:lemma) { |n| "text_#{ n }" }
    ne_class 'NP00G00'
  end

  factory :name_entity, class: NamedEntity do
    text     "Elias Seman"
    ne_class :people
    form     "Elias_Seman"
    lemma    "elias_seman"
    tag      "NP00SP0"
    document
  end

  factory :place_entity, class: NamedEntity do
    text     "ESMA"
    ne_class :places
    form     "esma"
    lemma    "esma"
    tag      "NP00G00"
    document
  end

  factory :date_entity, class: NamedEntity do
    text "14 de julio de 2011"
    ne_class :dates
    form  "14_de_julio_de_2011"
    lemma "[??:14/7/2011:??.??:??]"
    tag   "W"
    document
  end

  factory :action_entity, class: ActionEntity do
    text     "nació"
    form     "nació"
    lemma    "nacer"
    tag      "VMIS3S0"
    document
  end

  factory :fact_register do
    document
  end

  factory :person do
    sequence(:name) { |n| "name_#{ n }" }
  end

  factory :address do
    sequence(:name) { |n| "name_#{ n }" }
  end

  factory :place do
    sequence(:name) { |n| "name_#{ n }" }
  end

  factory :organization do
    sequence(:name) { |n| "name_#{ n }" }
  end

  factory :date, class: DateEntity do
    sequence(:name) { |n| "name_#{ n }" }
  end

  factory :page do
    num 1
    from_pos 0
    to_pos 4020
  end

  factory :invitation do
    name 'John'
    email 'email@email.com'
    reason 'reason'
  end

  factory :contact do
    name 'John'
    email 'email@email.com'
    organization 'Organization'
    message 'This is a message'
  end
end
