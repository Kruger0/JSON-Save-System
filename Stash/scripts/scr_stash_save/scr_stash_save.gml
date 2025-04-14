/*
	[]==========================================================[]
	||                    	Stash Save/Load System for GMS2		||
	||                    										||
	||                    				          --KrugDev		||
	||	https://github.com/Kruger0/Stash						||
	[]==========================================================[]
*/

///@desc This funcion takes a filename and a struct, saving it as a json style file in plain text or encrypted.
///@arg	{String} filename The name of the file to save as.
///@arg	{Struct} struct	The data that will be saved.
///@arg	{Bool} encypt If the file should be encrypted or not.
///@pure
function stash_save(_filename, _struct, _encrypt = STASH_ENCRYPT) {
	var _buffer;
    var _string = json_stringify(_struct, true); 
	var _size	= string_byte_length(_string);
	
    if (_encrypt) {
		// Create a checksum of the data
		var _buffer_text = buffer_create(_size, buffer_fixed, 1);
		buffer_seek(_buffer_text, buffer_seek_start, 0);
		buffer_write(_buffer_text, buffer_text, _string);		
		var _chksm = buffer_crc32(_buffer_text, 0, _size);
		
		// Create a buffer containing the hash + string data
		var _buffer_temp = buffer_create(_size + 4, buffer_fixed, 1);
		buffer_seek(_buffer_temp, buffer_seek_start, 0);
		buffer_write(_buffer_temp, buffer_u32, _chksm);
		buffer_copy(_buffer_text, 0, _size, _buffer_temp, 4);
		
		// ARC4 encryption
		_buffer = stash_arcfour_process(STASH_PRIVATE_KEY, _buffer_temp);
		
		// Compression using zlib
		_buffer = buffer_compress(_buffer, 0, _size + 4);
		
		// Clear data
		buffer_delete(_buffer_text);
		buffer_delete(_buffer_temp);
    } else {
        _buffer = buffer_create(_size, buffer_fixed, 1);
		buffer_seek(_buffer, buffer_seek_start, 0);
		buffer_write(_buffer, buffer_text, _string);
    }
	
    buffer_save(STASH_PATH + _buffer, _filename);
    buffer_delete(_buffer);
	stash_trace($"[Stash] - File \"{_filename}\" saved at {filename_path(_filename)}");
}
