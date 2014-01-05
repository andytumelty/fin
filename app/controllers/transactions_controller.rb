class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:edit, :update, :destroy]

  # GET /transactions
  def index
    @transactions = current_user.transactions.order(date: :asc, created_at: :asc)
    respond_to do |format|
      format.html {
        @transaction_filter = {description: nil}
        @new_transaction = Transaction.new    
      }
      format.csv {
        send_data @transactions.to_csv
      }
    end
  end

  def filter
    @transaction_filter = transaction_filter_params
    puts @transaction_filter.inspect
    @transactions = current_user.transactions.order(date: :asc, created_at: :asc)
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
    @new_transaction = Transaction.new(transaction_params)

    if @new_transaction.save
      redirect_to transactions_path, notice: 'Transaction was successfully created.'
    else
      @transaction_filter = {description: nil}
      @transactions = current_user.transactions.order(:date)
      render action: 'index'
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

  def import
  end

  def load_import
    @@load_errors = []
    CSV.foreach(params[:file].path,headers: true) do |row|
      user_txs = current_user.transactions
      t = user_txs.find_by_id(row["id"]) || new
      t.attributes = row.to_hash.slice("date", "description", "amount")
      t.account = Account.where(name: row["account"], user: current_user).first || Account.create(name: row["account"], user: current_user)
      t.category = Category.where(name: row["category"], user: current_user).first || Category.create(name: row["category"], user: current_user)
      if t.save
      else
        @@load_errors << t.errors
      end
    end
    puts @@load_errors.inspect
    flash[:notice] = 'Import complete'
    render 'import'
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
