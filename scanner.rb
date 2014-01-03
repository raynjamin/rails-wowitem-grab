urls = (1..106000).map { |n| "http://us.battle.net/api/wow/item/#{n}" }

EventMachine.run {
	EM::Iterator.new(urls, 20).map(proc { |url, iter|
		http = EventMachine::HttpRequest.new(url).get

		http.errback { |res|
			puts "500 ERROR: ".red + res.inspect
			iter.return(res)
		}

	    http.callback { |res|
	    	jsData = JSON.parse(res.response)

    		# nok means bad request.
    		# make sure it's nil.
    		# itemClass = 2 is a weapon, 4 is armor. 
    		if jsData["nok"] == nil and (jsData["itemClass"] == 2 or jsData["itemClass"] == 4)
    			item = Wowitem.create(
    				:blizzid => jsData["id"],
    				:inventory_type => jsData["inventoryType"],
    				:item_class => jsData["itemClass"],
    				:item_subclass => jsData["itemSubClass"],
    				:name => jsData["name"],
    				:quality => jsData["quality"]
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