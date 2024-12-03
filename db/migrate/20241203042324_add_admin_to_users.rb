class AddAdminToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :is_admin, :boolean, default: false
  end
end
