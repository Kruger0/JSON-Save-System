
// Save
stash_save(global.config, "config.json", false)
stash_save(global.data, "data.sav")

// Load
global.config = stash_load("config.json", {
	audio : {
		master	: 1.0,
		music	: 1.0,
		sfx		: 1.0,
	},
	video : {
		resolution: "1920x1080",
		fullscreen : true,
	},
	language: "EN-US",
}, false)

global.data = stash_load("data.sav", {
	player : {
		life : 100,
		coins : 20,
		inventory : {
			weapon : "Sword",
		},
	},
})