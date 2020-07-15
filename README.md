# Monadencraft
Docker setup + config for the good old monadencraft server.

## Configuration
* Server: 1.16.1 ([Paper](https://papermc.io/))
* Seed: TBA
* Gamemode: survival
* Difficulty: hard
* Whitelist: on

## Mods
* [mcMMO](https://mcmmo.org/)
* [EssentialsX](https://essentialsx.net/)
* [SilkSpawners](https://dev.bukkit.org/projects/silkspawners)
* [BlockLocker](https://www.spigotmc.org/resources/blocklocker.3268/)

## Datapacks
* See [`/datapacks`](tree/master/datapacks)

## Paper performance tweaks
Minor ways in which the server differs from vanilla.
If something doesn't work as expected, one of these is probably to blame.

* `use-faster-eigencraft-redstone: true` (default false)
    - faster redstone; semantically equivalent to vanilla in theory
* `optimize-explosions: true` (default false)
    - faster explosions; morally equivalent to vanilla
* `max-auto-save-chunks-per-tick: 12` (default 24)
    - improved IO performance
* `per-player-mob-spawns: true` (default false)
    - prevents mob farms from hogging all spawns
* `max-entity-collisions: 4` (default 8)
    - improved cow farm performance
* `bed-search-radius: 2` (default 1)
    - make it harder to accidentally obstruct your bed
* `container-update-tick-rate: 4` (default 1)
    - refresh player view of container contents 5 times per second instead of 20;
      reduces network traffic and CPU load
* `non-player-arrow-despawn-rate: 200` (default: no despawning)
    - despawn skeleton/pillager arrows after 10 seconds; improves memory use
      and CPU load
* `mob-spawner-tick-rate: 2` (default 1)
    - halve spawn frequency from spawners for lighter CPU load
* `disable-chest-cat-detection: true` (default false)
    - cats don't prevent chests from opening, for less irritation and lighter
      CPU load
* `hopper.cooldown-when-full: true` (default true)
    - reduce CPU load by not constantly trying to pull items into a full hopper
* Cobblestone despawns in 15 seconds.
    - reduce CPU load, memory usage, and inventory clutter when mining