class ChangeStatusTypeInOrders < ActiveRecord::Migration[8.0]
  def change
    change_column :orders, :status, :integer, using: 'status::integer'
  end
end
