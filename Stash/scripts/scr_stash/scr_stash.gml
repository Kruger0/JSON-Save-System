/*
	[]==========================================================[]
	||                    	Stash Save/Load System for GMS2		||
	||                    										||
	||                    				          --KrugDev		||
	||	https://github.com/Kruger0/Stash						||
	[]==========================================================[]
*/

//=============================================================
#region Stash Configuration

#macro STASH_SAVE_SECURE	true			// Obfuscate the file information
#macro STASH_FORCE_DEFAULT	false			// Force the stash_default() to use the default data instead of the save file
#macro STASH_DEBUG_TRACE	true			// Traces stash save/load messages

#endregion
//=============================================================

//=============================================================
#region Stash Functions

///@func stash_save(filename, struct, [secure])
function stash_save(_filename, _struct, _secure = STASH_SAVE_SECURE) {
	var _buffer;
    var _string = json_stringify(_struct, true); 
	var _size = string_byte_length(_string)
    if (_secure) {
		var _buffer_chksm = buffer_create(_size, buffer_fixed, 1)
		buffer_seek(_buffer_chksm, buffer_seek_start, 0)
		buffer_write(_buffer_chksm, buffer_text, _string)		
		var _chksm = buffer_crc32(_buffer_chksm, 0, _size)
		var _buffer_temp = buffer_create(_size + 4, buffer_fixed, 1);
		buffer_seek(_buffer_temp, buffer_seek_start, 0)
		buffer_write(_buffer_temp, buffer_u32, _chksm);
		buffer_copy(_buffer_chksm, 0, _size, _buffer_temp, 4)
		_buffer = buffer_compress(_buffer_temp, 0, _size + 4)
		buffer_delete(_buffer_chksm)
		buffer_delete(_buffer_temp)
    } else {
        _buffer = buffer_create(_size, buffer_fixed, 1)
		buffer_seek(_buffer, buffer_seek_start, 0)
		buffer_write(_buffer, buffer_text, _string)
    }    
    buffer_save(_buffer, _filename);
    buffer_delete(_buffer);
	if (STASH_DEBUG_TRACE) show_debug_message($"[Stash] - File \"{_filename}\" saved at {filename_path(_filename)}")
}

///@func stash_load(filename)
function stash_load(_filename) {
	if (file_exists(_filename)) {
		var _buffer = buffer_load(_filename); 
		buffer_seek(_buffer, buffer_seek_start, 0)		
		if (buffer_read(_buffer, buffer_u16) == 0x9C78) {
			var _buffer_old = _buffer
			_buffer = buffer_decompress(_buffer)
			buffer_delete(_buffer_old)
			buffer_seek(_buffer, buffer_seek_start, 0)
		}
		var _chksm1 = buffer_read(_buffer, buffer_u32)
		var _size = buffer_get_size(_buffer)
		var _buffer_chksm = buffer_create(_size - 4, buffer_fixed, 1)
		buffer_copy(_buffer, 4, _size - 4, _buffer_chksm, 0)
		var _chksm2 = buffer_crc32(_buffer_chksm, 0, _size - 4)
		var _string = buffer_read(_buffer, buffer_text)
		buffer_delete(_buffer_chksm)
		buffer_delete(_buffer)
		if (_chksm1 == _chksm2) {
			var _struct = json_parse(_string)
			if (STASH_DEBUG_TRACE) show_debug_message($"[Stash] - File \"{_filename}\" loaded from {filename_path(_filename)}")
			return _struct
		} else {
			if (STASH_DEBUG_TRACE) show_debug_message($"[Stash] - File \"{_filename}\" is corrupted}")
		}
	} else {
		if (STASH_DEBUG_TRACE) {
			show_debug_message($"[Stash] - File \"{_filename}\" not found. Loading default data")
		}
	}
	return -1
}

function stash_default(_filename, _default = {}, _secure = STASH_SAVE_SECURE) {
	if !(STASH_FORCE_DEFAULT) {
		if (file_exists(_filename)) {
			var _buffer = buffer_load(_filename); 
			buffer_seek(_buffer, buffer_seek_start, 0)		
			if (buffer_read(_buffer, buffer_u16) == 0x9C78) {
				var _buffer_old = _buffer
				_buffer = buffer_decompress(_buffer)
				buffer_delete(_buffer_old)
				buffer_seek(_buffer, buffer_seek_start, 0)
			}
			var _chksm1 = buffer_read(_buffer, buffer_u32)
			var _size = buffer_get_size(_buffer)
			var _buffer_chksm = buffer_create(_size - 4, buffer_fixed, 1)
			buffer_copy(_buffer, 4, _size - 4, _buffer_chksm, 0)
			var _chksm2 = buffer_crc32(_buffer_chksm, 0, _size - 4)
			var _string = buffer_read(_buffer, buffer_text)
			buffer_delete(_buffer_chksm)
			buffer_delete(_buffer)
			if (_chksm1 == _chksm2) {
				var _struct = json_parse(_string)
				var _keys = struct_get_names(_default)
				for (var i = 0; i < array_length(_keys); i++) {
					var _key = _keys[i]
					_struct[$ _key] ??= _default[$ _key]
				}			
				if (STASH_DEBUG_TRACE) show_debug_message($"[Stash] - File \"{_filename}\" loaded from {filename_path(_filename)}")
				return _struct
			} else {
				if (STASH_DEBUG_TRACE) show_debug_message($"[Stash] - File \"{_filename}\" is corrupted. Loading default data}")
			}
		} else {
			if (STASH_DEBUG_TRACE) {
				show_debug_message($"[Stash] - File \"{_filename}\" not found. Loading default data")
			}
		}
	}	
	stash_save(_filename, _default)
	return _default
}

#endregion
//=============================================================