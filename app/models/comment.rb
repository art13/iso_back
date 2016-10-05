class Comment < ActiveRecord::Base
	belongs_to :product
	belongs_to :comment
end