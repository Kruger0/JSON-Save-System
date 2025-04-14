
// Startup
global.data = stash_default("data.sav", {
	player : {
		x : room_width/2,
		y : room_height/2,
		coins : 0,
	},
	coins : []
})

stash_save(global.data, "data.sav")

global.config = stash_default("config.json", {
	fullscreen : false,
	lang : "EN-US",
	audio: 0.5,
}, false)

// Custom save/load
data_save = function() {
	
	// Save player data
	if (instance_exists(obj_player)) {
		global.data.player.x = obj_player.x
		global.data.player.y = obj_player.y
	}
	
	// Save coins data
	global.data.coins = []
	for (var i = 0; i < instance_number(obj_coin); i++) {
		var _coin = instance_find(obj_coin, i)
		array_push(global.data.coins, {
			x : _coin.x,
			y : _coin.y,
		})
	}
	
	stash_save("data.sav", global.data)
}

data_load = function() {
	
	global.data = stash_load("data.sav")
	show_message(global.data)
	// Load player data
	if (instance_exists(obj_player)) {
		obj_player.x = global.data.player.x
		obj_player.y = global.data.player.y
	} else {
		instance_create_layer(global.data.player.x, global.data.player.y, layer, obj_player)
	}
	
	// Load coins data
	with (obj_coin) {
		instance_destroy()
	}

	for (var i = 0; i < array_length(global.data.coins); i++) {
		var _inst = global.data.coins[i]
		instance_create_layer(_inst.x, _inst.y, layer, obj_coin)
	}
}

data_load()

// Debug
dbg_view("Stash Demo", true, 16, 32, 350, 100)
dbg_section("Save and Load")
dbg_button("Save", ref_create(self, "data_save"))
dbg_same_line()
dbg_button("Load", ref_create(self, "data_load"))