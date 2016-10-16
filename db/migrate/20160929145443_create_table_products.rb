class CreateTableProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
    	t.string :name
    	t.string :permalink
    	t.attachment :photo
    	t.string :time_id
    	t.integer :category_id
    	t.jsonb :properties, :default => {}
        t.string :code, :default => ""
        t.text :description, :default => ""
        t.decimal :price, :default => 0.0
        t.jsonb :sample_products, :default => {}
        t.timestamps
    end
  end
end
