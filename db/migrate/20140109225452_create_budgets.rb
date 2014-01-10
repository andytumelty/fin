class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.decimal :balance, :precision => 19, :scale => 4
      t.references :user, index: true

      t.timestamps
    end
  end
end
