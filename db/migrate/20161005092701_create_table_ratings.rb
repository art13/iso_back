class CreateTableRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :ratings do |t|
    	t.integer :product_id
    	t.integer :comment_id
    	t.decimal :rating, :default => 4.5
    end
  end
end
