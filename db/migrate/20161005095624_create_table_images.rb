class CreateTableImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
    	t.integer :product_id
    	t.string :name
    	t.attachment :file
    	t.timestamps
    end
  end
end
