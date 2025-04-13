
// Stash System - Functions
//=============================================================

///@func stash_save(struct, filename, [secure])
function stash_save(_struct, _filename, _secure = STASH_SAVE_SECURE) {
	var _buffer;
    var _string = json_stringify(_struct, true); 
    if (_secure) {
        var _b64 = base64_encode(_string);
        _buffer = buffer_create(string_byte_length(_b64)+1, buffer_fixed, 1);
        buffer_write(_buffer, buffer_string, _b64);
    } else {
        _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
        buffer_write(_buffer, buffer_string, _string);
    }    
    buffer_save(_buffer, _filename);
    buffer_delete(_buffer);
	if (STASH_DEBUG_TRACE) show_debug_message($"[Stash] - File \"{_filename}\" saved at {filename_path(_filename)}")
}

///@func stash_load(filename, default, [secure])
function stash_load(_filename, _default, _secure = STASH_SAVE_SECURE) {
	if (!file_exists(_filename)) {
		show_debug_message($"[Stash] - File \"{_filename}\" not found. Loading default data", true)
		return _default
	}
	
    var _buffer = buffer_load(_filename); 
	
	if !(buffer_exists(_buffer)) {
		show_debug_message($"[Stash] - File \"{_filename}\" could not be loaded. Loading default data", true)
		return _default
	}
	
    var _string = buffer_read(_buffer, buffer_string);
	var _struct = {};
	
	try {
		_struct = json_parse(_string);
	} catch(error) {
		try {
			_struct = json_parse(base64_decode(_string));
		} catch(error) {
			show_debug_message($"[Stash] - File \"{_filename}\" could not be read. Loading default data", true);
			return _default
		}
	}

	var _blank_keys = struct_get_names(_default)
	for (var i = 0; i < array_length(_blank_keys); i++) {
		var _blank_key = _blank_keys[i]
		_struct[$ _blank_key] ??= _default[$ _blank_key]
	}
    
    buffer_delete(_buffer);
	if (STASH_DEBUG_TRACE) show_debug_message($"[Stash] - File \"{_filename}\" loaded from {filename_path(_filename)}")
    return _struct;
}
