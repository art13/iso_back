class CreateTableLineItems < ActiveRecord::Migration[5.0]
  def change
    create_table :line_items do |t|
    	t.integer :order_id
    	t.integer :product_id
    	t.integer :count
    	t.float :price
    end
  end
end
