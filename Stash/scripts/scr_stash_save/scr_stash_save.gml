/*
	[]==========================================================[]
	||                    	Stash Save/Load System for GMS2		||
	||                    										||
	||                    				          --KrugDev		||
	||	https://github.com/Kruger0/Stash						||
	[]==========================================================[]
*/

///@func stash_save(filename, struct, [secure])
function stash_save(_filename, _struct, _secure = STASH_SAVE_SECURE) {
	var _buffer;
    var _string = json_stringify(_struct, true); 
	var _size = string_byte_length(_string);
    if (_secure) {
		var _buffer_chksm = buffer_create(_size, buffer_fixed, 1);
		buffer_seek(_buffer_chksm, buffer_seek_start, 0);
		buffer_write(_buffer_chksm, buffer_text, _string);		
		var _chksm = buffer_crc32(_buffer_chksm, 0, _size);
		var _buffer_temp = buffer_create(_size + 4, buffer_fixed, 1);
		buffer_seek(_buffer_temp, buffer_seek_start, 0);
		buffer_write(_buffer_temp, buffer_u32, _chksm);
		buffer_copy(_buffer_chksm, 0, _size, _buffer_temp, 4);
		_buffer = stash_arcfour_process(STASH_PRIVATE_KEY, _buffer_temp);
		_buffer = buffer_compress(_buffer, 0, _size + 4);
		buffer_delete(_buffer_chksm);
		buffer_delete(_buffer_temp);
    } else {
        _buffer = buffer_create(_size, buffer_fixed, 1);
		buffer_seek(_buffer, buffer_seek_start, 0);
		buffer_write(_buffer, buffer_text, _string);
    }	
    buffer_save(_buffer, _filename);
    buffer_delete(_buffer);
	if (STASH_DEBUG_TRACE) show_debug_message($"[Stash] - File \"{_filename}\" saved at {filename_path(_filename)}");
}
