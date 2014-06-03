class BudgetsController < ApplicationController
  before_filter :require_login
  before_action :set_budget, only: [:show, :edit, :update, :destroy]

  # FIXME prevent viewing budgets that aren't yours
  # FIXME prevent editing budgets that aren't yours
  # FIXME prevent deleting budgets that aren't yours

  # GET /budgets
  def index
    @budgets = current_user.budgets
  end

  # GET /budgets/1
  def show
    if @budget.blank?
      redirect_to new_budget_url, notice: 'No budgets found'
    else
      @budgets = current_user.budgets.order(start_date: :asc)
      @previous_budget = @budgets.where("start_date < :start_date", start_date: @budget.start_date).last
      @next_budget = @budgets.where("start_date > :start_date", start_date: @budget.start_date).first
      @budgeted_reservations = @budget.reservations.where(ignored: false).order(amount: :desc)
      @ignored_reservations = @budget.reservations.where(ignored: true)
      @new_reservation = Reservation.new
      # TODO change to be only categories that don't already have a reservation in this budget
      @categories = current_user.categories.where.not(id: @budgeted_reservations.pluck(:category_id)).order(name: :asc)
    end
  end

  # GET /budgets/new
  def new
    @budget = Budget.new
  end

  # GET /budgets/1/edit
  def edit
  end

  # POST /budgets
  def create
    @budget = Budget.new(budget_params)
    @budget.user = current_user
    @budget.balance = 0
    if @budget.name.blank?
      @budget.name = @budget.start_date.to_s + " to " + @budget.end_date.to_s
    end
    p(@budget)
    if @budget.save
      redirect_to @budget, notice: 'Budget was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /budgets/1
  def update
    if @budget.update(budget_params)
      redirect_to @budget, notice: 'Budget was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /budgets/1
  def destroy
    @budget.destroy
    redirect_to budgets_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_budget
      if params[:id] == "latest"
        @budget = current_user.budgets.order(start_date: :asc).last
      else
        @budget = current_user.budgets.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def budget_params
      params.require(:budget).permit(:name, :start_date, :end_date, :balance, :user_id)
    end
end
