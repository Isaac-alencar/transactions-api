# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Transactions' do
  explanation 'Transactions resource'

  get '/transactions' do
    let!(:transactions) { create_list(:transaction, 4) }
    context '200' do
      example_request 'list all transactions' do
        expect(response_status).to eq(200)
        expect(response_body).to eq(transactions.to_json)
      end
    end
  end

  get '/transactions/:transaction_id' do
    context '200' do
      parameter :transaction_id, 'string', required: true, type: :string

      let!(:transaction) { create(:transaction) }

      example 'list a transaction with id' do
        do_request(transaction_id: transaction.transaction_id)

        expect(response_status).to eq(200)
        expect(response_body).to eq(transaction.to_json)
      end
    end

    context '404' do
      example_request 'list a transaction with id - error' do
        do_request

        expect(response_status).to eq(404)
        expect(response_body).to eq({ message: 'Transaction not found!' }.to_json)
      end
    end
  end

  post '/transactions' do
    parameter :amount, 'number', required: true
    parameter :user_id, 'number', required: true
    parameter :card_holder, 'string', required: true
    parameter :card_number, 'string', required: true
    parameter :card_expiration_date, 'string', required: true
    parameter :card_security_code, 'string', required: true

    context '201' do
      let(:user) { create(:user) }
      let(:transaction_params) { attributes_for(:transaction, user_id: user.id) }

      example 'create a new transaction' do
        header 'Content-Type', 'application/json'

        do_request({ data: { transaction: transaction_params } })

        expect(response_status).to eq(201)
      end
    end

    context '422' do
      let(:user) { create(:user) }
      let(:transaction_params) { attributes_for(:transaction, :invalid_amount, user_id: user.id) }
      example 'create a new transaction - error example' do
        header 'Content-Type', 'application/json'

        do_request({ data: { transaction: transaction_params } })

        expect(response_status).to eq(422)
      end
    end
  end

  patch 'transactions/:transaction_id' do
    parameter :status, %i[approved denied], required: true

    # # Define request body example as a JSON object
    let(:raw_post) { params.to_json }

    context '200' do
      let(:transaction) { create(:transaction) }
      let(:transaction_id) { transaction.transaction_id }

      example 'updates a transaction status' do
        header 'Content-Type', 'application/json'

        do_request(transaction: { status: 'approved' })

        expect(response_status).to eq(200)
        expect(JSON.parse(response_body)['message']).to eq('Transaction updated successfully')
      end
    end

    context '422' do
      let(:transaction) { create(:transaction, status: :approved) }
      let(:transaction_id) { transaction.transaction_id }

      example 'updates a transaction status - error' do
        header 'Content-Type', 'application/json'

        do_request(transaction: { status: 'approved' })

        expect(response_status).to eq(422)
        expect(JSON.parse(response_body)['message']).to eq("Can't change a denied or approved transaction!")
      end
    end
  end
end
