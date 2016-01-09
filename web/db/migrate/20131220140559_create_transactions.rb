class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.date :date
      t.string :description
      t.decimal :amount, :precision => 19, :scale => 4
      t.references :account, index: true
      t.references :category, index: true

      t.timestamps
    end
  end
end
