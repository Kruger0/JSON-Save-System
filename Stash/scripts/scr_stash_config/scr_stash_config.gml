/*
	[]==========================================================[]
	||                    	Stash Save/Load System for GMS2		||
	||                    										||
	||                    				          --KrugDev		||
	||	https://github.com/Kruger0/Stash						||
	[]==========================================================[]
*/

#macro STASH_PATH			""
#macro STASH_ENCRYPT		true				// Obfuscate the file information
#macro STASH_FORCE_DEFAULT	false				// Force the stash_load() to use the default data instead of the save file
#macro STASH_TRACE			true				// Traces stash save/load messages
#macro STASH_PRIVATE_KEY	"Ar5c!9zM]K&Q4@bP"	// Your private secure key. Change it before using the system

///@ignore
function stash_trace(_string) {
	if (STASH_TRACE) {
		show_debug_message($"[Stash] - {_string}");
	}
}