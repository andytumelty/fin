class CreateRemoteAccountTypes < ActiveRecord::Migration
  def change
    create_table :remote_account_types do |t|
      t.string :title

      t.timestamps
    end
  end
end
