class AddToCategoryNestedAttrs < ActiveRecord::Migration[5.0]
  def change
  	# add_column :categories, :lft, :integer, :index => true
   #  add_column :categories, :rgt, :integer, :index => true
    add_column :categories, :show_on_front, :boolean, :default => false
    add_column :categories, :position, :integer, :index => true
  end
end
