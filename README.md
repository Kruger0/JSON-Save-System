<h1 align="center">Stash 1.0</h1>
 A buffer based save/load system for GameMaker

How to use!
1. Import the script to your game
2. Edit the EmptySave constructor. It will be your default structure
   for saving game data
3. Acess your game data by the global.gamedata or by the macro JSON_DATA
   E.g. obj_player.life = JSON_DATA.player.life
