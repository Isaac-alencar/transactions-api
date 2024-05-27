# frozen_string_literal: true

class Transaction < ApplicationRecord
  before_save :set_transaction_id

  belongs_to :user

  enum status: { pending: 0, approved: 1, denied: 2 }

  validates :card_holder, presence: true
  validates :card_number, presence: true
  validates :card_expiration_date, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_id, presence: true, uniqueness: true, on: :save
  validates :card_security_code, presence: true, numericality: { only_integer: true }, length: { is: 3 }

  # custom validations
  validate :expiration_date

  def expiration_date
    # Ensure that the card is not expired yet
    year = card_expiration_date.split('/').last.to_i

    errors.add(:card_expiration_date, 'The card is already expired') if year < Date.today.year
  end

  private

  def set_transaction_id
    self.transaction_id = Digest::UUID.uuid_v4
  end
end
