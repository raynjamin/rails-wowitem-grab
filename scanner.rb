#wow item 
urls = (1..106000).map { |n| "http://us.battle.net/api/wow/item/#{n}" }

EventMachine.run {
  EM::Iterator.new(urls, 20).map(proc { |url, iter|
    http = EventMachine::HttpRequest.new(url).get
    http.errback { |res|
      puts "500 ERROR: ".red + res.inspect
      iter.return(res)
    }
	  http.callback { |res|
	    js_data = JSON.parse(res.response)
      
      # nok means bad request.
    	# make sure nok isn't part of jsData
    	# itemClass = 2 is a weapon, 4 is armor.
      # we want those.
    	if js_data["nok"] == nil && (js_data["itemClass"] == 2 || js_data["itemClass"] == 4) then
    	  item = WowItem.create(
    		  blizzid: js_data["id"],
    		  inventory_type: js_data["inventoryType"],
    			item_class: js_data["itemClass"],
    			item_subclass: js_data["itemSubClass"],
    			name: js_data["name"],
    			quality: js_data["quality"]
    		)
        
        puts "Inserted #{ item.blizzid.to_s.green }:#{ item.name.light_blue }."
	    else
	      puts "Missing Item or Bad Request: #{ res.response.light_red }"
	    end
        
			iter.return(res)
		}
  }, proc { |responses| 
	  puts 'Process finished.'.green 
    EventMachine.stop
  })
}
