class RenameReservationTransactionsToReservationsTransactions < ActiveRecord::Migration
  def up
    execute "
      ALTER VIEW
        reservation_transactions
        RENAME TO 
        reservations_transactions
    ;"
  end

  def down
    execute "
      ALTER VIEW
        reservations_transactions
        RENAME TO 
        reservation_transactions
    ;"
  end
end
