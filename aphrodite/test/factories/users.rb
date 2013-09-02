# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "example#{n}@example.com" }
    password '123456'
    password_confirmation { password }
    confirmed_at Time.zone.now
    # sequence(:username) { |n| "username#{n}" }

    factory :user_with_project do
      after(:create) do |user|
        Project.create :user => user
      end
    end
  end
end
