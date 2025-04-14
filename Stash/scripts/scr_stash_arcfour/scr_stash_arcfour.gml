/*
	[]==========================================================[]
	||                    	Stash Save/Load System for GMS2		||
	||                    										||
	||                    				          --KrugDev		||
	||	https://github.com/Kruger0/Stash						||
	[]==========================================================[]
*/

// RC4 - ARCFOUR Implementation
// Sources
// https://marketplace.gamemaker.io/assets/9192/gmarcfour
// https://en.wikipedia.org/wiki/RC4

///@ignore
function stash_arcfour_state(_key) {
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