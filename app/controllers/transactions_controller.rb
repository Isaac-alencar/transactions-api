# frozen_string_literal: true

class TransactionsController < ActionController::API
  before_action :set_transaction, only: %i[show update]

  def index
    @transactions = Transaction.all

    render json: @transactions, status: :ok
  end

  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      render json: @transaction, status: :created
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @transaction, status: :ok
  end

  def update
    unless @transaction.pending?
      render json: { message: "Can't change a denied or approved transaction!" },
             status: :unprocessable_entity
      return
    end

    return unless @transaction.update!(update_transaction_params)

    render json: { message: 'Transaction updated successfully' }, status: :ok
  end

  private

  def transaction_params
    params
      .require(:data)
      .require(:transaction).permit(:card_holder, :card_number, :card_security_code,
                                    :card_expiration_date, :amount, :user_id)
  end

  def update_transaction_params
    params.require(:transaction).permit(:status)
  end

  def set_transaction
    @transaction = Transaction.find_by!(transaction_id: params[:transaction_id])
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Transaction not found!' }, status: :not_found
  end
end
