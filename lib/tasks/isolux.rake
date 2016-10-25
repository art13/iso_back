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
			
 	@base_uri  = "http://isolux.ru"
 	@limit = 100
 	@heads.each do |head|
 		puts "== start parse #{head[:name]} =="
 		@page = open_uri(@base_uri + "/" + head[:permalink])
 		@parent_category = Category.find_by_site_permalink(clear_permalink(head[:permalink])) || 
 							Category.create(:shop_id => 1, :name => head[:name], :site_permalink => clear_permalink(head[:permalink]), :time_id => time_id_generation(clear_permalink(head[:permalink]),""))
 		unless @parent_category.nil?
 			second_round = compile(@page, @parent_category)
 			puts "1 #{second_round}"
 			second_round.each do |second|
 				puts "2 #{second}"
 				if second[:name] != "Товары по акции"	
	 				second_category = Category.find_by_time_id(second[:time_id]) || Category.create(second)
	 				pager = @base_uri + "/" + clear_permalink(head[:permalink])+ "/" + second[:site_permalink] + ".html"
	 				puts "#{pager}"
	 				third_round = compile(open_uri(open(pager)), second_category)
	 				puts "third round"
	 				third_round.each do |round|
	 					Category.find_by_time_id(round[:time_id]) || Category.create(round)
	 				end
	 			end
 				puts "end of third round"
 			end
 			
 			puts "end of second round"
 		end
 		puts "== end =="
 	end
 	@all_products = 0
 	Category.where(:parent_id => 0).each do |parent|	
 	#@categories_array = Category.where(:parent_id => 0).last.children.map{|c| [c.parent.site_permalink, c.site_permalink]}
 		@categories_array = parent.children.map{|c| [parent.site_permalink, c.site_permalink]}
 		puts "#{@categories_array}"
 		parse_products(@categories_array, parent.name, @all_products)
 	end
 	puts "#{@all_products}"
end
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																															
def clear_permalink(permalink)
	permalink.split(".").first
end

def compile(page, parent)
	page.css(".categoryNavig ul li a").map{|a| {:shop_id => 1, :site_permalink => clear_permalink(a['href'].split('/').last), :name => a.text, :parent_id => parent.id, :time_id =>time_id_generation(clear_permalink(a['href'].split('/').last,), parent.site_permalink)}}
end

def parse_products(categories_array, parent, all_products)
	links = []
	@products = []
	@categories = Category.all
	categories_array.each do |uri_arr|
	    print "Парсинг категории " + uri_arr.join("/") + " ..."
	    itms = get_items_links(uri_arr)
	    # puts "#{itms}"
	    #links.concat itms
	    all_products += itms.length.to_i
	    puts all_products
	    puts itms.length.to_s + ' товаров'
	    puts "Подготовлено к парсингу #{links.length} товаров."

		starting_parse_items(itms, @categories)

	    puts "товары  добавлены в базу данных"
	end
	puts "-- Парсинг категории #{parent} завершён --"
end

def build_uri(uri_array, page=nil)
	@base_uri = "http://isolux.ru"
	uri = "#{@base_uri}/#{uri_array.join('/')}.html?limit=#{@limit}"
	uri += page ? "&p=#{page}" : ""
	uri
end

def get_max_page(uri_array)
	doc = open_uri(build_uri(uri_array, 500))
	pg = doc.css('.isolux-pagination li a')
	pg.length===0 ? 1 : pg.last.inner_text.to_i
end	

def get_items_links(uri_arr)
	links = []
	(1..get_max_page(uri_arr) ).each do |x|
		links.concat get_css_list(build_uri(uri_arr), '.item .product-name a')
	end
	links
end

def get_css_list(uri, css_selector, attrib = "href")
	items = []
	open_uri(uri).css(css_selector).each{ |i| items.push i[attrib] }
	items
end

def get_css(uri, css_selector, index)
	open_uri(uri).css(css_selector)[index]
end

def open_uri(uri)
	puts "#{uri}"
	Nokogiri::HTML(open(uri))
end

def time_id_generation(permalink, parent_permalink)
	product_time_id(parent_permalink + permalink)
end

def product_time_id(name)
	Digest::MD5.hexdigest(name)
end

def starting_parse_items(links, categories)
	puts "Начало парсинга товаров"
	num = 0
	@new_products = []
	@images = []
	links.each  do |link|
	    num += 1
	    print "Парсинг категории , #{num*100 / links.length} % завершено \r"
	    begin
			parse_item(link, @categories, @new_products, @images) # thread
		 rescue => e
		 	puts "error #{e}"
		 end
	end
	Product.create(@new_products)	
	Image.create(@images.map{|i| {:product_id => Product.find_by_permalink(i[:product]).id, :file => i[:image] }})

end

def parse_item(uri, categories, new_products, new_images)
		
		@update_products = []
		@products = []
		doc = open_uri(uri)
		out = {}
		@images = []
		
		out[:name] = doc.css('.product-container .cart_title_product h1 span').inner_text.strip
		out[:permalink] = uri.split("/")[3].split(".")[0].gsub("-","_")
		out[:time_id] = product_time_id(out[:permalink])
		
		picc = doc.css('.product_image a')
		out[:photo] = picc.length==0 ? "" : URI.parse(picc[0]['href'].split("?").first)
		begin
			category_tray = categories.find_by_time_id(get_category_id(doc))
			out[:category_id] = category_tray.nil? ? categories.find_by_time_id(get_category_id(doc, -3)).id : category_tray.id 
		rescue
		 	out[:category_id] =  new_products.last[:category_id]
		 	puts "#{get_category_id(doc)}"
		 	puts "#{get_category_id(doc, -3)}"
		 end
		props = []
		x = doc.css('#product-attribute-specs-table th').map{|a| a.css(".wrap_word").text.strip.squish}
		y = doc.css('#product-attribute-specs-table td').map{|a| a.text.strip.squish}
		(0..x.size-1).each do |i|
			o = {}

		    o[:key] = x[i]
		    o[:val] = y[i]
		
		    props.push o
		end
		out[:code] = doc.css("#super-product-table tbody td.ac").inner_text.strip.split(" ").first
		out[:price] = doc.css("#super-product-table tbody td.cost3 .regular-price .price").text.squish.split(",").first.gsub(" ", "").to_f
		out[:description] = doc.css("#full-description p").map{|x| "<p>#{x.text.strip}</p>" unless x.text.blank?}.join
		out[:properties] = props.uniq.to_json
		imgs = doc.css(".product_left_info .small_img .gallery_elements").map{|a| a.attr("href").split("?").first}.uniq
		imgs.shift
		puts "==== #{imgs} ---"
		Array(imgs).each do |i|
			begin
				@images << {:image => URI.parse(i), :product => out[:permalink]}
			rescue Exception => e
				e
			end
		end
		puts "#{out}"
		puts "#{@images}"	
		@current_product = Product.find_by_time_id(out[:time_id])
		puts "#{@current_product}" 
		if @current_product.nil?  
			new_products << out 
			new_images << @images
		else
		 	@current_product.update_attributes(out)
		 	unless @images.empty?
			 	@current_product.images.destroy_all
			 	@current_product.images.create(@images.map{|i| {:file => i[:image]}})
			end
		end
		puts "#{new_products.size}"
end

def rest_get(zone, id=nil)
	Unirest.get(build_rest_uri(zone,id)).body
end
	
def rest_search(zone, term)
	xuri = build_rest_uri(zone) + "?search=#{term}"
	Unirest.get( URI.escape(xuri)).body
end

def build_rest_uri(zone, id=nil)
		uri = "#{@rest_uri}/#{zone}"
		uri += (id.nil?) ? "" : "/#{id}"
		uri += ".json"
		uri
end

def get_category_id(doc, step=-2)
	raw_cat = doc.css('ol.isolux-breadcrumb li')[step].css("a").attr("href").text
	puts "------- #{raw_cat} ---------"
	cat_link = raw_cat.split(".html").first.split("/").last(2).join
	puts cat_link
	product_time_id(cat_link)
end
