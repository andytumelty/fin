class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:edit, :update, :destroy]
  before_action :set_transactions, only: [:index, :filter]
  before_action :set_accounts_and_categories, only: [:index, :filter]

  def index
    respond_to do |format|
      format.html {
        #@transactions = @transactions.where(date: (Date.today-1.month..Date.today))
        @transaction_filter = {description: nil, date_from: Date.today - 1.month, date_to: Date.today}
        @new_transaction = Transaction.new(category: current_user.categories.where(name: "unassigned").first)
        @category_breakdown = set_category_breakdown(@transactions)
        @total_income, @total_expenditure, @balance_diff = set_metrics(@transactions)
      }
      format.csv {
        send_data @transactions.to_csv
      }
    end
  end

  def filter # FIXME category and account selected don't persist
    @transaction_filter = transaction_filter_params
    if @transaction_filter[:date_from].present? && @transaction_filter[:date_to].present?
      @transactions = @transactions.where(date: (@transaction_filter[:date_from]..@transaction_filter[:date_to]))
    end
    if @transaction_filter[:budget_date_from].present? && @transaction_filter[:budget_date_to].present?
      @transactions = @transactions.where(budget_date: (@transaction_filter[:budget_date_from]..@transaction_filter[:budget_date_to]))
    end
    if @transaction_filter[:description].present?
      @transactions = @transactions.where("description ILIKE :search", search: "%#{@transaction_filter[:description]}%")
    end
    if @transaction_filter[:category].present?
      category = current_user.categories.where(name: @transaction_filter[:category]).first
      @transactions = @transactions.where(category: category)
    end
    if @transaction_filter[:account].present?
      account = current_user.accounts.where(name: @transaction_filter[:account]).first
      @transactions = @transactions.where(account: account)
    end
    @category_breakdown = set_category_breakdown(@transactions)
    @total_income, @total_expenditure, @balance_diff = set_metrics(@transactions)
    @new_transaction = Transaction.new
    render 'index'
  end

  def edit
  end

  def create
    @new_transaction = Transaction.new(transaction_params)
    if @new_transaction.budget_date.blank?
      @new_transaction.budget_date = @new_transaction.date
    end
    if @new_transaction.save
      # mark transaction and any after to be updated
      # for each, mark reservations that need to be updated
      # trigger balance updater
      redirect_to transactions_path, notice: 'Transaction was successfully created.'
    else
      @transaction_filter = {description: nil}
      @transactions = current_user.transactions.order(:date)
      render action: 'index'
    end
  end

  def update
    @transaction.recalculate = true
    if @transaction.update(transaction_params)
      # mark transaction and any after to be updated
      # for each, mark reservations that need to be updated
      # trigger balance updater
      redirect_to transactions_path, notice: 'Transaction was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
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
    if params[:file].blank?
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
          # mark transaction and any after to be updated
          # for each, mark reservations that need to be updated
          successful += 1
        else
          @@import_errors << [row.to_hash, t.errors.full_messages]
          errors += 1
        end
      end
      # trigger balance updater
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
      @transaction = current_user.transactions.find(params[:id])
    end

    def set_transactions
      @transactions = current_user.transactions.includes(:account, :category).order(date: :desc, order: :desc)
    end

    def set_accounts_and_categories
      @accounts = current_user.accounts.order(name: :asc)
      @categories = current_user.categories.order(name: :asc)
    end

    def transaction_params
      params.require(:transaction).permit(:order, :date, :budget_date, :description, :amount, :account_id, :category_id)
    end

    def transaction_filter_params
      params.permit(:date_from, :date_to, :budget_date_from, :budget_date_to, :description, :account, :category)
    end

    def set_category_breakdown(transactions)
      category_breakdown = Hash.new
      current_user.categories.each do |category|
        category_transactions = transactions.where(category: category)
        if category_transactions.present?
          category_breakdown[category.name] = category_transactions.sum('amount')
        end
      end
      category_breakdown = Hash[category_breakdown.sort_by{|key, val| val}.reverse]
      return category_breakdown
    end

    def set_metrics(transactions)
      total_income = transactions.where('amount > 0').sum('amount') # TODO Is this useful? Transfers skew this
      total_expenditure = transactions.where('amount < 0').sum('amount')
      balance_diff = total_income + total_expenditure
      return [total_income, total_expenditure, balance_diff]
    end
end
