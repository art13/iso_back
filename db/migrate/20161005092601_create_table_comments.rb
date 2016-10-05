class CreateTableComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
    	t.string :autor
    	t.integer :product_id
    	t.text :comment, :default => ""
    	t.timestamps
    end
  end
end
