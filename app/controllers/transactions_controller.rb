class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:edit, :update, :destroy]

  # GET /transactions
  def index
    @accounts = current_user.accounts
    @categories = current_user.categories
    @transactions = current_user.transactions.includes(:account, :category).order(date: :asc, order: :asc)
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
    @transactions = current_user.transactions.order(date: :asc, order: :asc)
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
  def create # TODO if no budget date is set, use date
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
    # if date, order, date, amount, account are changed, update balance and account balance for all transactions after this
    if @transaction.update(transaction_params)
      redirect_to transactions_path, notice: 'Transaction was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /transactions/1
  def destroy
    # update balance and account balance for all transactions after this
    @transaction.destroy
    redirect_to transactions_path
  end

  def import
  end

  def load_import
    # change to a method in an import controller?
    @@import_errors = [] # FIXME move import errors from class var to session
    successful = 0
    errors = 0
    if params[:file].nil?
      flash[:alert] = "No file selected!"
      redirect_to transactions_import_path
    else
      CSV.foreach(params[:file].path,headers: true) do |row|
        user_txs = current_user.transactions
        t = user_txs.find_by_id(row["id"]) || Transaction.new
        t.attributes = row.to_hash.slice("order", "date", "budget_date", "description", "amount")
        t.account = Account.where(name: row["account"], user: current_user).first || Account.create(name: row["account"], user: current_user)
        t.category = Category.where(name: row["category"], user: current_user).first || Category.create(name: row["category"], user: current_user)
        if t.save
          successful += 1
        else
          @@import_errors << [row.to_hash, t.errors.full_messages]
          errors += 1
        end
      end
      #puts @@import_errors.inspect
      notice = "Import complete: #{successful.to_s} successfully imported"
      if errors > 0
        notice += ", #{errors.to_s} skipped through errors (#{view_context.link_to("Download errors as CSV", transactions_import_errors_path(format: "csv"))})"
      end
      flash[:notice] = notice.html_safe
      redirect_to transactions_path
    end
  end

  def import_errors
    respond_to do |format|
      format.csv {
        file = CSV.generate do |csv|
          keys = @@import_errors[0][0].keys
          keys << "error"
          csv << keys
          puts @@import_errors.inspect
          #puts @@import_errors[0][0].keys.inspect
          @@import_errors.each do |e|
            row = []
            e[0].values.each do |val|
              row << val
            end
            row << e[1][0]
            csv << row
          end
        end
        send_data file
      }
    end
  end

  private
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    def transaction_params
      params.require(:transaction).permit(:order, :date, :budget_date, :description, :amount, :account_id, :category_id)
    end

    def transaction_filter_params
      params.permit(:description, :account_id, :category_id)
    end

end
