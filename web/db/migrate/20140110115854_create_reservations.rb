class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.references :category, index: true
      t.decimal :amount, precision: 19, scale: 4
      t.decimal :balance, precision: 19, scale: 4
      t.boolean :ignored, default: false
      t.references :budget, index: true

      t.timestamps
    end
  end
end
