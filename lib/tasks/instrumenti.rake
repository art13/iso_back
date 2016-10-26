# [{:name=>"Товары для отдыха", :permalink=>"otdyh.vseinstrumenti.ru/"}]
task :parse_instrumenti => :environment do
	@url = "http://www.vseinstrumenti.ru"	
	@heads = [{:name=>"Инструмент", :permalink=>"instrument"}, 
	{:name=>"Все для сада", :permalink=>"sadovaya_tehnika"}, 
	{:name=>"Ручной инструмент", :permalink=>"ruchnoy_instrument"}, 
	{:name=>"Силовая техника", :permalink=>"silovaya_tehnika"}, 
	{:name=>"Станки", :permalink=>"stanki"},
	{:name=>"Техника для климата, уборки", :permalink=>"klimat"}, 
	{:name=>"Электрика и свет", :permalink=>"electrika_i_svet"},
	{:name=>"Строительное оборудование", :permalink=>"stroitelnaya_tehnika_i_oborudovanie"}, 
	{:name=>"Автосервисное оборудование", :permalink=>"avtogarazhnoe_oborudovanie"},
 	{:name=>"Расходка, крепеж, спецодежда", :permalink=>"rashodnie_materialy"}]#,
 	# {:name=>"Товары для отдыха", :permalink=>"otdyh"}]
 	@page = open_uri(@url)
 	@links = []

 	(1..10).each do |i|
	 	@categories = @page.css("#rubrikator li.menu-item #submenu-#{i} .setHeight div").map{|a| get_categories_list(a) unless a.css("a.level2").blank?}.compact
	 	#struct {:lvl1 => {:name, :site_permalink }, :lvl2 => [{:parent => {:name, :site_permalink}, :lvl3 => [{:name, :site_permalink}]}]}
	 	@categories.flatten.each do |category|
		 	puts "#{category[:lvl1]}}"
		 	c_id = create_category(category[:lvl1])
		 	category[:lvl2].each do |lvl2|
		 		c2_id = create_category(lvl2[:parent], category[:lvl1][:site_permalink], c_id)
		 		if lvl2[:lvl3].empty?
		 			@links << @url + "#{lvl2[:parent][:site_permalink]}"
		 		else
		 			lvl2[:lvl3].each do |sub|
		 				create_category(sub, lvl2[:parent][:site_permalink], c2_id)
		 				@links << @url + sub[:site_permalink] 
		 			end
	 			end
	 		end
	 	end
	end
	start_parse_catalog(@url, @links.uniq)
end

def start_parse_catalog(url, links, limit=50)
	@categories = Category.instr
	@items = []
	links.each do |link|
		@links = []
	 	(1..limit).each do |i|
	 		mod_link = nil
	 		mod_link = i > 1 ?  "#{link}page#{i}#goods" : link 
	 		begin
	 			pge = open_uri(mod_link)
	 			puts "add #{mod_link}"
	 			@links.concat get_links(pge.css(".catalogItem .goodBlock .catalogItemName a"), link)
	 			puts "#{@links.size}"
	 		rescue => e
	 			puts "=====ERROR====="
		  		puts "#{mod_link}"
		  		puts e
		  		puts "==============="
		  		break
	 		end
		end
		parse_items(@links, url, @categories)

	end
	# puts "#{@items.size}"
	# @items.uniq.each do |link|
	# 	puts "parse #{link}"
	# 	page = open_uri(link)

	# 	@links.concat get_links(page.css(".catalogItem .goodBlock .catalogItemName a"))
	# 	puts "#{@links.size}"
	#end
	puts "#{@links.uniq.size}"
	puts "#{@links.size}"
end

def parse_items(links, url, categories)
	num = 0
	@new_products = []
	links.each do |link|
		
		f_link = fix_link(link[:product], url)
		begin
			parse_product(f_link, @new_products, categories, link[:category])
		rescue => e
			puts "===== ERROR in product ====="
		  	puts "#{link}"
		  	puts e
		  	puts "============================"
		end
		num += 1
	    print "Парсинг категории , #{num*100 / links.length} % завершено \r"
	end
	Product.create(@new_products)
end

def parse_product(uri, new_products, categories, category_link)
		doc = open_uri(uri)
		out = {}
		@images = []
		
		out[:name] = doc.css(".content h1").inner_text.strip
		out[:permalink] = uri.split("/").last
		out[:time_id] = product_time_id(out[:permalink])
		begin
		puts "#{category_link}"
		puts "#{product_time_id(category_link)}"
			category_id = categories.find_by_site_permalink(category_link)
			puts "#{category_id}"
			out[:category_id] = category_id.nil? ? 0 : category_id.id 
		 rescue
			out[:category_id] =  new_products.last[:category_id]
		end
		props = []
		
		# doc.css("#goodThValue .thValueBlock").map{|a| [a.css(".thName").text, a.css(".thValue").text]}
		doc.css("#goodThValue .thValueBlock").each do |x| 
		    o = {}
		    o[:key] = x.css('.thName').inner_text.strip
		    o[:val] = x.css('.thValue').inner_text.strip
		
		    props.push o
		end
		out[:code] = doc.css("#aboveImageBlock .codeToOrder").inner_text
		out[:price] = doc.css(".price-value").inner_text.gsub(" ", "").to_f
		out[:description] = doc.css("#tab1_content .fs-13.c-gray3 p").inner_text
		out[:properties] = props.uniq
		picc = doc.css("#goods-img-block a.image img").attr("src").text.gsub("461x415", "300x300").gsub("//","http://")
		out[:photo] = picc.length==0 ? "" : URI.parse(picc)
		puts "#{out}"
		@current_product = Product.find_by_time_id(out[:time_id])
		puts "#{@current_product}" 
		if @current_product.nil?  
			new_products << out 
			#new_images << @images
		else
		 	@current_product.update_attributes(out)
		 # 	unless @images.empty?
			#  	@current_product.images.destroy_all
			#  	@current_product.images.create(@images.map{|i| {:file => i[:image]}})
			# end
		end
		puts "#{new_products.size}"
end

def category_id(page)
		
end

def fix_link(link, url)
	fix_link = 
		if link.include? "http://" 
		 	link 
		else
		 	url+link
		end
end

def get_links(css, link)
	cat = link.split(".ru").last
	xx = css.map{|x| {:product => x.attr("href"), :category => cat}}.compact
	puts "=> #{xx}"
	xx
end

def get_categories_list(page)
	{:lvl1 => get_level_1_category(page), :lvl2 => get_level_2_category(page)}
end

def get_level_1_category(page)
	{:name => page.css("a.level2").text, :site_permalink => page.css("a.level2").attr("href").text}
end

def get_level_2_category(page)
	puts "111"
	puts "#{page.css("ul.nowrap .dspl_ib .subcats .level3").map{|p| p.css('div')}}"
	page.css("ul.nowrap .dspl_ib .subcats .level3").map{|p| {:parent => get_level_2_parent(p), :lvl3 => get_level_3_category(p)} unless p.css('div').empty?}.compact
end

def get_level_2_parent(page)
	puts "#{page}"
	puts "#{page.css("div a").nil?}"
	{:name => page.css("div a").text, :site_permalink => page.css("div a").attr("href").text} unless page.css("div a").empty?

end

def get_level_3_category(page)
	page.css("ul.childs li a").map{|x| {:name => x.text, :site_permalink => x.attr("href")}}
end

def create_category(item, perm = nil, parent_id = 0)
	time_id = perm.nil? ? product_time_id(item[:site_permalink]) : time_id_generation(item[:site_permalink], perm)
	category = Category.find_by_time_id(time_id) || Category.create(item.merge({:shop_id => 2, :time_id => time_id, :parent_id => parent_id}))
	return category.id
end