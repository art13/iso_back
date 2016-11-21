class CreateTableTaxonProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :taxon_products do |t|
    	t.integer :product_id, :index => true
    	t.integer :taxon_id, :index => true
    end
  end
end
