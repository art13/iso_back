# u="http://www.vseinstrumenti.ru/"
# page.css("#rubrikator li.menu-item .itemMenuText").map{|x| x.inner_text} # head menu names
# page.css("#rubrikator li.menu-item #submenu-1 .nowrap .dspl_ib").map{|a| a.css(".subcats .level3 div a").text} # level 2 menu names
# page.css("#rubrikator li.menu-item #submenu-1 .nowrap .dspl_ib").map{|a| a.css(".subcats .level3 .childs li a").map{|x| x.text}} #level 3 menu names
# heads = page.css("#rubrikator li.menu-item").map{|x| {:name => x.css(".itemMenuText").text, :permalink => x.css(".dspl_n div a.level2").attr("href").text}}
	
 	# [{:name=>"Товары для отдыха", :permalink=>"otdyh.vseinstrumenti.ru/"}]
task :parse_instrumenti => :environment do 
	url = "http://www.vseinstrumenti.ru/"	
	@heads = [{:name=>"Инструмент", :permalink=>"instrument"}, 
	{:name=>"Все для сада", :permalink=>"sadovaya_tehnika"}, 
	{:name=>"Ручной инструмент", :permalink=>"ruchnoy_instrument"}, 
	{:name=>"Силовая техника", :permalink=>"silovaya_tehnika"}, 
	{:name=>"Станки", :permalink=>"stanki"},
	{:name=>"Техника для климата, уборки", :permalink=>"klimat"}, 
	{:name=>"Электрика и свет", :permalink=>"electrika_i_svet"},
	{:name=>"Строительное оборудование", :permalink=>"stroitelnaya_tehnika_i_oborudovanie"}, 
	{:name=>"Автосервисное оборудование", :permalink=>"avtogarazhnoe_oborudovanie"},
 	{:name=>"Расходка, крепеж, спецодежда", :permalink=>"rashodnie_materialy"}]
 	page = open_uri(url)
 	page.css("#rubrikator li.menu-item #submenu-1 .nowrap .dspl_ib").map{|a| a.css(".subcats .level3").map{|aa| {:name => aa.css("div a").text, :subs => aa.css("ul.childs li a").map{|x| {:name => x.text, :permalink => x.attr("href")}}}}}
end