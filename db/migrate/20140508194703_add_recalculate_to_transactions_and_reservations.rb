class AddRecalculateToTransactionsAndReservations < ActiveRecord::Migration
  def change
    add_column :transactions, :recalculate, :boolean
    add_column :reservations, :recalculate, :boolean
  end
end
