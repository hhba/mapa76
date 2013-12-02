# encoding: utf-8

FactoryGirl.define do
  factory :named_entity do
    sequence(:text) { |n| "text_#{ n }" }
    sequence(:lemma) { |n| "text_#{ n }" }
    ne_class 'NP00G00'
  end

  factory :person do
    sequence(:name) { |n| "name_#{ n }" }
  end

  factory :page do
  end

  factory :organization do
    sequence(:name) { |n| "name_#{ n }" }
  end
 
  factory :document do
    sequence(:title)             { |n| "text_#{ n }" }
    sequence(:original_filename) { |n| "text_#{ n }" }
    file { StringIO.new("") }
  end

  factory :name_entity, class: NamedEntity do
    text     "Elias Seman"
    ne_class :people
    form     "Elias_Seman"
    lemma    "elias_seman"
    tag      "NP00SP0"
    document
  end

  factory :organization_entity, class: NamedEntity do
    text     "Marina"
    ne_class :organizations
    form     "marina"
    lemma    "marina"
    tag      "NP00O00"
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
    pos   1
    document
  end

  factory :action_entity, class: ActionEntity do
    text     "nació"
    form     "nació"
    lemma    "nacer"
    tag      "VMIS3S0"
    document
  end

  factory :address_entity, class: NamedEntity do
    text     'Territorio 2709'
    form     'Territorio 2709'
    lemma    'territorio_2709'
    tag      'ADDRESS'
    ne_class :addresses
  end

  factory :fact_register do
    document
  end

  factory :user do
    sequence(:email) {|n| "example#{n}@example.com" }
    encrypted_password 123456
  end
end
