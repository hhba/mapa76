FactoryGirl.define do
  factory :document do
    sequence(:title)             { |n| "text_#{ n }" }
    sequence(:original_filename) { |n| "text_#{ n }" }

    file { StringIO.new("empty content") }

    trait :public do
      public true
    end

    trait :private do
      public false
    end
  end
end
