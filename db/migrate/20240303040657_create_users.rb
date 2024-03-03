class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :full_name
      t.string :phone_number
      t.text :address
      t.string :password_digest
      t.boolean :is_verified, default: false
      t.timestamps
    end
  end
end
