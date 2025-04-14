/*
	[]==========================================================[]
	||                    	Stash Save/Load System for GMS2		||
	||                    										||
	||                    				          --KrugDev		||
	||	https://github.com/Kruger0/Stash						||
	[]==========================================================[]
*/

///@func stash_save(filename, struct, [encrypt])
///@description				This funcion takes a filename and a struct, saving it as a json style file in plain text or encrypted.
///@arg	{String} filename	The name of the file to save as.
///@arg	{Struct} struct		The data that will be saved.
///@arg	{Bool} [encypt]		If the file should be encrypted or not.
///@pure
function stash_save(_filename, _struct, _encrypt = STASH_ENCRYPT) {
	var _file	= STASH_PATH + _filename
    var _string = json_stringify(_struct, true); 
	var _size	= string_byte_length(_string);
	var _buffer;
	
    if (_encrypt) {
		// Create a checksum of the data
		var _buffer_text = buffer_create(_size, buffer_fixed, 1);
		buffer_seek(_buffer_text, buffer_seek_start, 0);
		buffer_write(_buffer_text, buffer_text, _string);		
		var _chksm = buffer_crc32(_buffer_text, 0, _size);
		
		// Create a buffer containing the checksum + string data
		var _buffer_temp = buffer_create(_size + 4, buffer_fixed, 1);
		buffer_seek(_buffer_temp, buffer_seek_start, 0);
		buffer_write(_buffer_temp, buffer_u32, _chksm);
		buffer_copy(_buffer_text, 0, _size, _buffer_temp, 4);
		
		// ARC4 encryption
		var _buffer_arc4 = stash_arcfour_process(STASH_KEY, _buffer_temp);
		
		// Compression using zlib
		_buffer = buffer_compress(_buffer_arc4, 0, _size + 4);
		
		// Clear data
		buffer_delete(_buffer_text);
		buffer_delete(_buffer_temp);
		buffer_delete(_buffer_arc4);
    } else {
        _buffer = buffer_create(_size, buffer_fixed, 1);
		buffer_seek(_buffer, buffer_seek_start, 0);
		buffer_write(_buffer, buffer_text, _string);
    }
	
    buffer_save(_buffer, _file);
    buffer_delete(_buffer);
	stash_trace($"[Stash] - File \"{filename_name(_file)}\" saved at {filename_path(_file)}");
}

///@description				This funcion takes a filename and a default struct. If the file exists, then it will be loaded and returned as a struct. If if does not exists, a new file will be created with the default values.
///@arg	{String} filename	The name of the file to load.
///@arg	{Default} [struct]	The default values that should be loaded.
///@arg	{Bool} [encypt]		In case of reading the file for the first time, if the created save should be enctypted or not.
///@return {Struct}
function stash_load(_filename, _default = undefined, _encrypt = STASH_ENCRYPT) {
	var _file = STASH_PATH + _filename
	
	// Stash disabled situation
	if (!STASH_ENABLED && _default != undefined) {
		stash_save(_filename, _default, _encrypt);
		return _default;
	}
	
	if (file_exists(_file)) {
		var _buffer = buffer_load(_file);
		buffer_seek(_buffer, buffer_seek_start, 0);
		
		// If the buffer is encrypted, decrypt it
		if (buffer_read(_buffer, buffer_u16) == 0x9C78) {
			
			// Decompression using zlib
			var _buffer_arc4 = buffer_decompress(_buffer);
			buffer_delete(_buffer);
			
			// ARC4 decryption
			buffer_seek(_buffer_arc4, buffer_seek_start, 0);
			var _buffer_temp = stash_arcfour_process(STASH_KEY, _buffer_arc4);
			var _size = buffer_get_size(_buffer_temp) - 4;
			buffer_delete(_buffer_arc4);
			
			// Separate the buffer contanining the checksum + string
			var _chksm = buffer_read(_buffer_temp, buffer_u32);
			_buffer = buffer_create(_size, buffer_fixed, 1);
			buffer_copy(_buffer_temp, 4, _size, _buffer, 0);
			buffer_delete(_buffer_temp);
			
			// Compare the two checksums
			if (_chksm != buffer_crc32(_buffer, 0, _size)) {
				stash_trace($"[Stash] - File \"{filename_name(_file)}\" is corrupted.");
				buffer_delete(_buffer);
				
				// Save and return the default data
				stash_save(_filename, _default, _encrypt);
				return _default;
			}
		}
		
		// Parse file into a struct
		buffer_seek(_buffer, buffer_seek_start, 0);
		var _string = buffer_read(_buffer, buffer_text);
		var _struct = json_parse(_string);
		
		// Copy keys that don't exists in the loaded file from the default data - as they're new entries
		if (is_struct(_default)) {
			stash_copy(_default, _struct)
		}	
		
		// Return the loaded data
		stash_trace($"[Stash] - File \"{filename_name(_file)}\" loaded from {filename_path(_file)}.");
		stash_save(_filename, _struct, _encrypt);
		return _struct;
	} else {
		if (is_struct(_default)) {
			stash_trace($"[Stash] - File \"{filename_name(_file)}\" will be loaded with the default data.");
			stash_save(_filename, _default, _encrypt);
			return _default;
		}
	}
	
	// Everything failed
	stash_trace($"[Stash] - File \"{filename_name(_file)}\" not found.");	
	return -1;
}

///@ignore
function stash_trace(_string) {
	if (STASH_TRACE) {
		show_debug_message($"[Stash] - {_string}");
	}
}

///@ignore
function stash_copy(_src, _dst) {
	var _keys = struct_get_names(_src);
	var _len = array_length(_keys);
	for (var i = 0; i < _len; i++) {
		var _key = _keys[i];
		
		// Copy undefined values
		_dst[$ _key] ??= _src[$ _key];
		
		// Deep search
		if (is_struct(_dst[$ _key])) {
			stash_copy(_src[$ _key], _dst[$ _key])
		}
	}
}

///@ignore
function stash_arcfour_state(_key) {
	// https://marketplace.gamemaker.io/assets/9192/gmarcfour
	// https://en.wikipedia.org/wiki/RC4
    var _state = array_create(256);
    var _key_size = string_byte_length(_key);
    for (var i = 0; i < 256; i++) {
        _state[i] = i;
    }
    var j = 0;
    for (var i = 0; i < 256; i++) {
        j = (j + _state[i] + string_byte_at(_key, (i % _key_size) + 1)) % 256;
        var temp = _state[i];
        _state[i] = _state[j];
        _state[j] = temp;
    }
    return _state;
}

///@ignore
function stash_arcfour_process(_key, _buffer) {
	// https://marketplace.gamemaker.io/assets/9192/gmarcfour
	// https://en.wikipedia.org/wiki/RC4
    var _size = buffer_get_size(_buffer);
    var _state = stash_arcfour_state(_key);
    var _temp_buff = buffer_create(_size, buffer_fixed, 1);
    var _original_pos = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var i = 0;
    var j = 0;    
    for (var n = 0; n < _size; n++) {
        i = (i + 1) % 256;
        j = (j + _state[i]) % 256;
        var temp = _state[i];
        _state[i] = _state[j];
        _state[j] = temp;
        var keystream_byte = _state[(_state[i] + _state[j]) % 256];
        var input_byte = buffer_read(_buffer, buffer_u8);
        buffer_write(_temp_buff, buffer_u8, keystream_byte ^ input_byte);
    }
    buffer_seek(_buffer, buffer_seek_start, _original_pos);
    buffer_seek(_temp_buff, buffer_seek_start, 0);    
    return _temp_buff;
}
