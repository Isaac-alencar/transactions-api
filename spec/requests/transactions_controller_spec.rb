# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsController, type: 'request' do
  describe 'GET /transactions' do
    context 'when there are transactions' do
      let!(:transactions) { create_list(:transaction, 4) }

      it 'returns a list of transactions' do
        get transactions_path

        expect(response).to have_http_status :ok
        expect(response.body).to eq(transactions.to_json)
      end
    end

    context 'when there is no transactions' do
      before { Transaction.delete_all }
      it 'returns an empty array' do
        get transactions_path

        expect(response).to have_http_status :ok
        expect(response.body).to eq([].to_json)
      end
    end
  end

  describe 'GET /transaction/:transaction_id' do
    context 'when a transaction was found' do
      let!(:transaction) { create(:transaction) }

      it 'returns the transaction with the given id' do
        get transaction_path(transaction.transaction_id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(transaction.to_json)
      end
    end

    context 'when a transaction was not found' do
      it 'returns an error message with 404 status' do
        get transaction_path('non-existent-transaction-id')

        expected_response = { message: 'Transaction not found!' }.to_json

        expect(response).to have_http_status(:not_found)
        expect(response.body).to eq(expected_response)
      end
    end
  end

  describe 'POST /transactions' do
    context 'when all params are valid' do
      let!(:user) { create(:user) }
      let(:transaction_params) { attributes_for(:transaction, user_id: user.id) }
      it 'creates a new transaction' do
        post transactions_path, params: { transaction: transaction_params }

        expect(response).to have_http_status(:created)
      end
    end

    context 'when param are invalid' do
      let!(:user) { create(:user) }

      let(:missing_param) { attributes_for(:transaction, :invalid_transaction, user_id: user.id) }
      let(:invalid_expiration_date) { attributes_for(:transaction, :card_expired, user_id: user.id) }
      let(:invalid_amount) { attributes_for(:transaction, :invalid_amount, user_id: user.id) }

      it 'does not creates a transaction with no amount' do
        post transactions_path, params: { transaction: missing_param }

        error_message = { "amount": ["can't be blank", 'is not a number'] }.to_json

        expect(response).to have_http_status :unprocessable_entity
        expect(response.body).to eq(error_message)
      end

      it 'does not creates a transaction with expired card' do
        post transactions_path, params: { transaction: invalid_expiration_date }

        error_message = { "card_expiration_date": ['The card is already expired'] }.to_json

        expect(response).to have_http_status :unprocessable_entity
        expect(response.body).to eq(error_message)
      end

      it 'does not creates a transaction with invalid amount' do
        post transactions_path, params: { transaction: invalid_amount }

        error_message = { "amount": ['must be greater than 0'] }.to_json

        expect(response).to have_http_status :unprocessable_entity
        expect(response.body).to eq(error_message)
      end
    end
  end

  describe 'PATCH /transactions/:transaction_id' do
    context 'when a transaction is pending' do
      let!(:transaction) { create(:transaction) }
      let!(:transaction_2) { create(:transaction) }

      let(:to_approved) { { transaction: { status: 'approved' } } }
      let(:to_denied) { { transaction: { status: 'denied' } } }

      expected_response = {
        "message": 'Transaction updated successfully'
      }.to_json

      it 'can be changed to approved' do
        patch transaction_path(transaction.transaction_id), params: to_approved

        expect(response).to have_http_status :ok
        expect(response.body).to eq(expected_response)
      end

      it 'can be changed to denied' do
        patch transaction_path(transaction_2.transaction_id), params: to_denied

        expect(response).to have_http_status :ok
        expect(response.body).to eq(expected_response)
      end
    end

    context 'when a transaction is denied or approved' do
      let!(:transaction) { create(:transaction, status: 'denied') }

      let(:to_approved) { { transaction: { status: 'approved' } } }
      let(:to_denied) { { transaction: { status: 'denied' } } }
      let(:to_pending) { { transaction: { status: 'pending' } } }

      expected_response = {
        "message": "Can't change a denied or approved transaction!"
      }.to_json

      it "can't be changed to any status" do
        patch transaction_path(transaction.transaction_id), params: to_approved

        expect(response).to have_http_status :ok
        expect(response.body).to eq(expected_response)
      end

      it "can't be changed to any status" do
        patch transaction_path(transaction.transaction_id), params: to_denied

        expect(response).to have_http_status :ok
        expect(response.body).to eq(expected_response)
      end

      it "can't be changed to any status" do
        patch transaction_path(transaction.transaction_id), params: to_pending

        expect(response).to have_http_status :ok
        expect(response.body).to eq(expected_response)
      end
    end
  end
end
