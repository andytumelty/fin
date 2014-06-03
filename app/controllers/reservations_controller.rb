class ReservationsController < ApplicationController
  before_filter :require_login
  before_action :set_reservation, only: [:edit, :update, :destroy]
  before_action :set_budget

  def new
    @reservation = Reservation.new
  end

  def edit
    @categories = current_user.categories
  end

  def create
    @reservation = Reservation.new(reservation_params)
    @reservation.budget = @budget
    if @reservation.save
      redirect_to @budget, notice: 'Reservation was successfully created.'
    else
      redirect_to @budget, notice: 'Reservation could not be created.'
    end
  end

  def update
    if @reservation.update(reservation_params)
      redirect_to @budget, notice: 'Reservation was successfully updated.'
    else
      redirect_to @budget, notice: 'Reservation could not be updated.'
    end
  end

  def destroy
    if @reservation.budget.user == current_user
      if @reservation.category_id.nil?
        flash[:error] = "You can't delete the everything else reservation!"
      else
        flash[:notice] = "Reservation destroyed"
        @reservation.destroy
      end
    else
      flash[:error] = "That's not your reservation!"
    end
    redirect_to @budget
  end

  private
    def set_budget
      @budget = current_user.budgets.find(params[:budget_id])
    end

    def set_reservation
      @reservation = current_user.reservations.find(params[:id])
    end

    def reservation_params
      params.require(:reservation).permit(:category_id, :amount, :balance, :ignored)
    end
end
