class AddFieldsToTableProducts < ActiveRecord::Migration[5.0]
  def change
  	add_column :products, :code, :string, :default => ""
  	add_column :products, :description, :text, :default => ""
  	add_column :products, :price, :decimal,  :default => 0.0
  	add_column :products, :sample_products, :jsonb, :default => {}
  end
end
