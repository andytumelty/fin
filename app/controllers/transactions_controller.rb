class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:edit, :update, :destroy]

  # GET /transactions
  def index
    @transaction_filter = {description: nil}
    @transactions = current_user.transactions.order(:date)
    #puts @transaction_filter[:description]
    #puts @transaction_filter[:description].empty?
    @new_transaction = Transaction.new
  end

  def filter
    @transaction_filter = transaction_filter_params
    puts @transaction_filter.inspect
    @transactions = current_user.transactions.order(:date)
    if !@transaction_filter[:description].nil?
      @transactions = @transactions.where("description ILIKE :search", search: "%#{@transaction_filter[:description]}%")
    end
    @new_transaction = Transaction.new
    render 'index'
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
      params.permit(:description, :account_id, :category_id)
    end

end
