#encoding: utf-8
task :parse_categories => :environment do 
	puts "start parsing"
	@heads = [{:name => "Стройматериалы", :permalink => 'stroymateriali.html'},
			{:name => "Отделочные материалы", :permalink => 'otdelochnie-materiali.html'},
			{:name => "Сантехника, отопление и водоснабжение", :permalink => 'santehnika.html'},
			{:name => "Электрика и освещение", :permalink => 'elektrotehnicheskoe-oborudovanie-1.html'},
			{:name => "Геоматериалы", :permalink => 'geomateriali.html'},
			{:name => "Инструмент и оборудование", :permalink => 'instrument-i-oborudovaniye.html'},
			{:name => "Дача и сад", :permalink => 'tovary-dlya-dachi-i-sada.html'}]
			
 	@main  = "http://isolux.ru"
 
 	@heads.each do |head|
 		puts "== start parse #{head[:name]} =="
 		@page = Nokogiri::HTML(open(@main + "/" + head[:permalink]))
 		@parent_category = Category.find_by_name(head[:name]) || Category.create(:name => head[:name], :permalink =>  clear_permalink(head[:permalink]))
 		unless @parent_category.nil?
 			second_round = @page.css(".categoryNavig ul li a").map{|a| [{:permalink => a['href'].split('/').last, :name => a.text, :parent_id => @parent_category.id}]}
 			puts "#{second_round}"
 			Category.create(second_round)
 		end
 		puts "== end =="
 	end
 	" end parsing"
end

def clear_permalink(permalink)
	permalink.split(".").first
end
