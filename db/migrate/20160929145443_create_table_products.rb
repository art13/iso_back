class CreateTableProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
    	t.string :name
    	t.string :name_t
    	t.attachment :photo
    	t.string :time_id
    	t.integer :category_id
    	t.jsonb :properties, :default => {}

    end
  end
end
