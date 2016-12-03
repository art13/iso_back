class CreateTableOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
    	t.string :code
    	t.integer :customer_id
    	t.float :total
    	t.integer :item_total
    	t.string :email
    	t.string :phone
    	t.string :address
    	t.string :name
    	t.string :last_name
    end
  end
end
