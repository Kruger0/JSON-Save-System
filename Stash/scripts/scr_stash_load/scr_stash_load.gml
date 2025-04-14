/*
	[]==========================================================[]
	||                    	Stash Save/Load System for GMS2		||
	||                    										||
	||                    				          --KrugDev		||
	||	https://github.com/Kruger0/Stash						||
	[]==========================================================[]
*/

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
			_buffer = stash_arcfour_process(STASH_PRIVATE_KEY, _buffer)
			var _chksm1 = buffer_read(_buffer, buffer_u32)
			var _size = buffer_get_size(_buffer)
			var _buffer_chksm = buffer_create(_size - 4, buffer_fixed, 1)
			buffer_copy(_buffer, 4, _size - 4, _buffer_chksm, 0)
			var _chksm2 = buffer_crc32(_buffer_chksm, 0, _size - 4)
			var _string = buffer_read(_buffer, buffer_text)
			buffer_delete(_buffer_chksm)			
			if (_chksm1 == _chksm2) {
				var _struct = json_parse(_string)
				if (STASH_DEBUG_TRACE) show_debug_message($"[Stash] - File \"{_filename}\" loaded from {filename_path(_filename)}")
				buffer_delete(_buffer)
				return _struct
			}
			if (STASH_DEBUG_TRACE) show_debug_message($"[Stash] - File \"{_filename}\" is corrupted}")
		}
		buffer_seek(_buffer, buffer_seek_start, 0)		
		var _string = buffer_read(_buffer, buffer_text)
		var _struct = json_parse(_string)
		if (STASH_DEBUG_TRACE) show_debug_message($"[Stash] - File \"{_filename}\" loaded from {filename_path(_filename)}")
		return _struct
	} else {
		if (STASH_DEBUG_TRACE) {
			show_debug_message($"[Stash] - File \"{_filename}\" not found. Loading default data")
		}
	}
	return -1
}