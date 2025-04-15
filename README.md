<h1 align="center">Stash 1.1</h1>
Stash is a save/load system made for GameMaker Studio 2, designed to handle game data and configuration files, including encryption and obfuscation using algorithms like checksum and ARCFOUR.



## How to use!

1. Use the function `stash_load()` with the file name and the default values to start the system:

    ```gml
    global.data = stash_load("data.sav", {
        life    : 80,
        gold    : 450,
        items   : [
            "Sword",
            "Shield",
            "Chestplate"
        ]
    })
    ```

2. Save the file with `stash_save()` when desired – on game end event or at the press of a button:

    ```gml
    stash_save("data.sav", global.data);
    ```

3. If you want to reload the file, just use `stash_load()` again:

    ```gml
    global.data = stash_load("data.sav");
    ```

---

## Credits
[GMArcFour](https://marketplace.gamemaker.io/assets/9192/gmarcfour)
