require 'string/similarity'

class RemoteAccountsController < ApplicationController
  # TODO before create and update check that remote account type exists
  before_filter :require_login
  before_action :set_account, only: [:new, :edit, :create, :update, :destroy, :get_credentials, :sync]
  before_action :set_remote_account, only: [:edit, :update, :destroy, :get_credentials, :sync]
  
  def index
    @remote_accounts = current_user.remote_accounts
  end

  def new
    @remote_account = RemoteAccount.new
    @remote_account_types = RemoteAccountType.all
  end

  def edit
    @remote_account = current_user.remote_accounts.find(params[:id])
    @remote_account_types = RemoteAccountType.all
  end

  def create
    @remote_account = RemoteAccount.new(remote_account_params)
    @remote_account.account = @account

    if @remote_account.save
      redirect_to accounts_path, notice: 'Remote Account was successfully created.'
    else
      @remote_account_types = RemoteAccountType.all
      render action: 'new'
    end
  end

  def update
    if @remote_account.update(remote_account_params)
      redirect_to accounts_path, notice: 'Remote Account was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @remote_account.destroy
    redirect_to accounts_path, notice: 'Remote Account was successfully deleted.'
  end

  def get_credentials
    @credentials = ['pin', 'password'] if @remote_account.remote_account_type.title == 'natwest'
    @credentials = ['password'] if @remote_account.remote_account_type.title == 'amex'
  end

  def sync
    credentials = credential_params
    unassigned = current_user.categories.where(name: 'unassigned').first
    
    start_date = Date.today.to_s
    last_synced = @remote_account.transactions.maximum(:remote_date)
    end_date = last_synced.nil? ? @remote_account.sync_from.to_s : [last_synced, @remote_account.sync_from].max.to_s

    # p(@remote_account)
    # p(@remote_account.remote_account_type)
    # p(@remote_account.remote_account_type.title)
    # p(credentials)
    transactions = []

    if @remote_account.remote_account_type.title == 'natwest'
      credentials['customer_number'] = @remote_account.user_credential
      Natwest::Customer.new.tap do |nw|
        nw.login credentials
        transactions = nw.transactions(end_date, start_date, @remote_account.remote_account_identifier).reverse
        #p transactions 
      end
    elsif @remote_account.remote_account_type.title == 'amex'
      client = Amex::Client.new(@remote_account.user_credential, credentials['password'])
      account = client.accounts.find{ |a| a.card_number_suffix = @remote_account.remote_account_identifier }
      raw_transactions = []  
      n = 0 
      while raw_transactions.find{ |t| t.date < Date.parse(end_date) }.nil? and n < 24 do
        raw_transactions += account.transactions(n)
        n += 1
      end
      raw_transactions.each do |r|
        transactions << { date: r.date, description: r.narrative, amount: r.amount }
      end 
    end

    #p(transactions)

    transactions.each do |t|
      if @remote_account.inverse_values
        t[:amount] = -t[:amount]
      end
      #puts "looking for #{t[:date]}, #{@account}, #{t[:amount]}"
      #potential_matches = current_user.transactions.where( date: t[:date], account: @account, amount: t[:amount])
      #puts "found #{potential_matches.count} potential matches"
      matching_transactions = current_user.transactions.where( date: t[:date], account: @account, amount: t[:amount]).select{ |m| String::Similarity.cosine( m.description.gsub(/Type.*/, ''), t[:description].gsub(/Type.*/, '')) > 0.7 }
      #puts matching_transactions.inspect

      if matching_transactions.count == 0
        t = Transaction.new(date: t[:date], description: t[:description], amount: t[:amount], account: @account, category: unassigned)
        t.save
        # puts t.errors.inspect
        # TODO did the transaction save successfully? where to pipe errors?
      end
    end
    # TODO check whether sync was successful and return: took x seconds, synced between, saved x transactions successfully, x failed
    redirect_to transactions_path, notice: 'sync complete, not sure if it was successful tho'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  
    def set_account
      @account = current_user.accounts.find(params[:account_id])
      puts @account.inspect
    end

    def set_remote_account
      @remote_account = current_user.remote_accounts.find(params[:id])
    end

    def credential_params
      params.require(:credentials).permit(:pin, :password)
    end

    def remote_account_params
      params.require(:remote_account).permit(:title, :inverse_values, :user_credential, :remote_account_identifier, :remote_account_type_id, :sync_from)
    end
end
