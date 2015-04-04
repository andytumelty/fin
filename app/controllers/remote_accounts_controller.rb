class RemoteAccountsController < ApplicationController
  before_filter :require_login
  before_action :set_account, only: [:new, :edit, :update, :destroy]
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
    @remote_account.account = Account.find(params[:account_id])

    if @remote_account.save
      redirect_to accounts_path, notice: 'Remote Account was successfully created.'
    else
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
      params.require(:remote_account).permit(:title, :inverse_values, :user_credential, :remote_account_identifier, :remote_account_type_id)
    end
end
