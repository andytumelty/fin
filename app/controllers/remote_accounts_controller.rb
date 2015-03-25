class RemoteAccountsController < ApplicationController
  before_filter :require_login
  before_action :set_account, only: [:edit, :update, :destroy]
  
  def index
    @remote_accounts = current_user.remote_accounts
  end

  def new
    @remote_account = RemoteAccount.new
    @remote_account_types = RemoteAccountType.all
  end

  def edit
    @remote_account_types = RemoteAccountType.all
  end

  def create
    @remote_account = RemoteAccount.new(remote_account_params)

    if @remote_account.save
      redirect_to index, notice: 'Remote Account was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @remote_account.update(remote_account_params)
      redirect_to index, notice: 'Remote Account was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @remote_account.destroy
    redirect_to index
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_remote_account
      @remote_account = RemoteAccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def remote_account_params
      params.require(:remote_account).permit(:account_id, :description, :inverse_values, :user_credential, :remote_account_identifier)
    end
end
