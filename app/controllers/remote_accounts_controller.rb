class RemoteAccountsController < ApplicationController
  # TODO before create and update check that remote account type exists
  before_filter :require_login
  before_action :set_account, only: [:new, :edit, :create, :update, :destroy]
  before_action :set_remote_account, only: [:edit, :update, :destroy]
  
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

  def sync_remote_account
    # get transactions until we find 3 that we've already got, or hit the remote_account.sync_from date

    #credentials = map from post vars and remote account details (or all from post?)
    Natwest::Customer.new.tap do |nw|
      nw.login credentials
      transactions = nw.transactions(ARGV[1], ARGV[2], ARGV[3]) # start, end, last 3 numbers, get from post
      #puts "Transactions for account ending #{ARGV[3]}, between #{ARGV[1]} and #{ARGV[2]}"
      #puts "Date       Description                                                 Amount"
      transactions.each do |t|
        # 
        #puts "#{t[:date]} #{sprintf('%-60.60s',t[:description])} #{sprintf('%9.2f', t[:amount])}"
      end
    end

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

    # Never trust parameters from the scary internet, only allow the white list through.
    def remote_account_params
      params.require(:remote_account).permit(:title, :inverse_values, :user_credential, :remote_account_identifier, :remote_account_type_id, :sync_from)
    end
end
