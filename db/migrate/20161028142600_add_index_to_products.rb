class AddIndexToProducts < ActiveRecord::Migration[5.0]
  def change
  	add_index :products, :properties
  	add_index :products, :permalink
  end
end
