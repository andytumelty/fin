class AddUpdateToTransactionsAndReservations < ActiveRecord::Migration
  def change
    add_column :transactions, :update, :boolean
    add_column :reservations, :update, :boolean
  end
end
