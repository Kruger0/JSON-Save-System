/*
	[]==========================================================[]
	||                    	Stash Save/Load System for GMS2		||
	||                    										||
	||                    				          --KrugDev		||
	||	https://github.com/Kruger0/Stash						||
	[]==========================================================[]
*/

#macro STASH_ENABLED	true				// If false, only the default struct will be used and no file will be loaded.
#macro STASH_ENCRYPT	true				// Encrypt the file information.
#macro STASH_TRACE		true				// Traces stash save/load messages.
#macro STASH_PATH		"stash\\"			// The directory witch the files will be stored.
#macro STASH_KEY		"Zf1MaWx9yPLt8qRo"	// Your private 16-byte encryption key. Change it before using the system.