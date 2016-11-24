#encoding: utf-8
task :mv_image_folders => :environment do
 	path = Rails.root.to_s + '/public/products/'
 	Product.all.map{|a| a.id}.each do |id|
 		puts id
 		begin
 			system "mv #{path+id.to_i.to_s} #{path+id}"
 		rescue => e
 			puts e
 		end
 	end
end