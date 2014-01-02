class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:edit, :update, :destroy]

  # GET /transactions
  def index
    @transaction_filter = transaction_filter_params
    @transactions = current_user.transactions.order(:date)
    @new_transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions
  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      redirect_to transactions_path, notice: 'Transaction was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /transactions/1
  def update
    if @transaction.update(transaction_params)
      redirect_to transactions_path, notice: 'Transaction was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /transactions/1
  def destroy
    @transaction.destroy
    redirect_to transactions_path
  end

  private
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    def transaction_params
      params.require(:transaction).permit(:date, :description, :amount, :account_id, :category_id)
    end

    def transaction_filter_params
      if params[:transaction_filter]
        params.require(:transaction_filter).permit(:description, :account_id, :category_id)
      else
        {description: nil, account_id: nil, category_id: nil}
      end
    end

end
