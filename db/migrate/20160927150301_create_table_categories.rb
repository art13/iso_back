class CreateTableCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
    	t.string :name, :default => ""
        t.integer :shop_id, :default => 0
    	t.integer :parent_id, :default => 0
    	t.string :url, :default => ""
    	t.string :permalink, :default => ""
        t.string :site_permalink, :default => ""
    	t.string :icon_type, :default => ""
    	t.string :time_id
    	t.attachment :image
    	t.timestamps
    end
  end
end
