class CreateRemoteAccounts < ActiveRecord::Migration
  def change
    create_table :remote_accounts do |t|
      t.string :title
      t.boolean :inverse_values
      t.string :user_credential
      t.string :remote_account_identifier
      t.references :account, index: true
      t.references :remote_account_type, index: true

      t.timestamps
    end
  end
end
