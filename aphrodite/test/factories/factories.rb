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

  factory :where_entity, class: NamedEntity do
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
end
