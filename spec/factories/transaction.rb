# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    card_holder { Faker::Name.name }
    card_number { Faker::Business.credit_card_number }
    card_expiration_date { Faker::Date.between(from: '2025-01-01', to: '2040-01-01').strftime('%m/%Y') }
    card_security_code { Faker::Number.between(from: 100, to: 999) }
    amount { Faker::Commerce.price }
    user
  end

  # any parama missing
  trait :invalid_transaction do
    amount { nil }
  end

  trait :invalid_amount do
    amount { Faker::Number.negative }
  end

  trait :card_expired do
    card_expiration_date { Faker::Date.between(from: '2014-01-01', to: '2015-01-01') }
  end

  trait :invalid_card_security_code do
    card_security_code { Faker::Number.between(from: 1000, to: 2000) }
  end
end
