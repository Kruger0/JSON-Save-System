
/*
	[]=========================================================[]
	||                    	Stash Save/Load System for GMS2	   ||
	||                    									   ||
	||                    				          --KrugDev	   ||
	[]=========================================================[]
	
	How to use!
	1. Import the script to your game
	2. Edit the EmptySave constructor. It will be your default structure
	   for saving game data
	3. Acess your game data by the global.gamedata or by the macro JSON_DATA
	   E.g. obj_player.life = JSON_DATA.player.life
	
	Important!
	json_save() is called by default at each 60 seconds, but you can deactivate that 
	and call it whenever you want, like in a Game End event on an obj_controller
*/

global.gamedata = {}						// Pre-defined variable to be used by the system. Can be whatever you whant

//============================================================= 
#region CONFIG

#macro JSON_FILENAME	"data.sav"			// File name to save
#macro JSON_ENCODE_B64	false				// Use Base64 encoding
#macro JSON_KEEPDATA	true				// Set to false to reset the save file
#macro JSON_TRACE		true				// Trace JSON file messages
#macro JSON_DATA		global.gamedata		// Variable to store the save info
#macro JSON_AUTOSAVE	true				// Autosave functionalty
#macro JSON_PERIOD		60					// Time in seconds to trigger the autosave

#endregion
//============================================================= 

//============================================================= 
#region EMPTY SAVE

function EmptySave() constructor {			// A base constructor containing the default values for the save file
	player = {
		life : 100,
		coins : 20,
		inventory : {
			weapon : "Sword",
		},
	}
	audio = {
		master	: 1.0,
		music	: 1.0,
		sfx		: 1.0,
	};
}

#endregion
//=============================================================

//=============================================================
#region FUNCTIONS

///@func json_save([data], [filename], [encoded])
function json_save(_struct = JSON_DATA, _filename = JSON_FILENAME, _encoded = JSON_ENCODE_B64) {
	var _buffer;
    var _string = json_stringify(_struct, true); 
    if (_encoded) {
        var _b64 = base64_encode(_string);
        _buffer = buffer_create(string_byte_length(_b64)+1, buffer_fixed, 1);
        buffer_write(_buffer, buffer_string, _b64);
    } else {
        _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
        buffer_write(_buffer, buffer_string, _string);
    }    
    buffer_save(_buffer, _filename);
    buffer_delete(_buffer);
	if (JSON_TRACE) show_debug_message($"JSON file \"{_filename}\" saved at {filename_path(_filename)}")
}

///@func json_load([filename], [empty_save])
function json_load(_filename = JSON_FILENAME, _empty_save = new EmptySave()) {
	if (!file_exists(_filename)) {
		show_debug_message($"JSON file \"{_filename}\" not found. Loading empty save", true)
		return new EmptySave()
	}
	
    var _buffer = buffer_load(_filename); 
	
	if !(buffer_exists(_buffer)) {
		show_debug_message($"JSON file \"{_filename}\" could not be loaded. Loading empty save", true)
		return new EmptySave()
	}
	
    var _string = buffer_read(_buffer, buffer_string);
	var _struct = {};
	
	try {
		_struct = json_parse(_string);
	} catch(error) {
		try {
			_struct = json_parse(base64_decode(_string));
		} catch(error) {
			show_debug_message($"JSON file \"{_filename}\" could not be read. Loading empty save", true);
			return new EmptySave()
		}
	}

	var _blank_keys = struct_get_names(_empty_save)
	for (var i = 0; i < array_length(_blank_keys); i++) {
		var _blank_key = _blank_keys[i]
		_struct[$ _blank_key] ??= _empty_save[$ _blank_key]
	}
    
    buffer_delete(_buffer);
	if (JSON_TRACE) show_debug_message($"JSON file \"{_filename}\" loaded from {filename_path(_filename)}")
    return _struct;
}

#endregion
//=============================================================

//=============================================================
#region STARTUP

if (JSON_KEEPDATA) {
	JSON_DATA = json_load()
} else {
	JSON_DATA = new EmptySave()
}
json_save(JSON_DATA, JSON_FILENAME)

#endregion
//=============================================================

//=============================================================
#region AUTOSAVE


if (JSON_AUTOSAVE) {
	call_later(JSON_PERIOD, time_source_units_seconds, json_save, true)
}

#endregion
//=============================================================