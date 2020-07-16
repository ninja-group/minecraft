# Ninja Group Minecraft Configuration
Docker setup + config for ninjas who craft in groups.

Also useful as a starting point for deploying your own server.
Plays nice with [thicc](https://github.com/valderman/thicc).

## Configuration
* **Server**: 1.16.1 ([Paper](https://papermc.io/))
* **Address**: `mc.ekblad.cc:25565`
* **Seed**: -4406778544368968670
* **Gamemode**: survival
* **Difficulty**: hard
* **PvP**: off

## Mods
* [mcMMO](https://mcmmo.org/)
* [EssentialsX](https://essentialsx.net/)
* [SilkSpawners](https://dev.bukkit.org/projects/silkspawners)
* [BlockLocker](https://www.spigotmc.org/resources/blocklocker.3268/)

## Datapacks
See [`datapacks`](datapacks) for all enabled datapacks.

Some particularly useful ones:
* **graves**: a gravestone is spawned when you die,
  to keep your inventory safe until you come back for it.
* **multiplayer sleep**: anyone can trigger a night → day transition
  (please be considerate of other players who may be engaged in
    night-time activities).
* **custom nether portals**: create nether portals in any shape you like.
* **more bricks crafting**: bricks are no longer a rare earth metal
  (craft four brick blocks from every four bricks instead of one).

See [vanillatweaks.net](https://vanillatweaks.net/picker/datapacks/) for
more information about each datapack.

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
* Cobblestone and netherrack despawn in 15 seconds.
    - reduce CPU load, memory usage, and inventory clutter when mining

## How to roll your own
Build or pull the docker image, `docker-compose up`, done.
Though you may want to change the config in [`docker-compose.yml`](docker-compose.yml) first.

### Available options
* Environment variables
  * `OPS`: space-separated list of users with op privileges.

    The effective list of ops is the union of this list and any users you have op'd
    from within Minecraft.
    You should probably have at least one name on this list, or managing
    your server is going to be a bit hard.
  * `ALLOW`: space-separated list of users who are allowed to connect
    to the server.

    The effective list of allowed users is the union of this list, the `OPS`
    list (no need do add ops to both lists) and any users you have added
    from within Minecraft using `/whitelist add`.
  * `HEAP`: amount of heap space to allocate. Defaults to `2G` if unset.
* Volumes
  * `/data`: your Minecraft world is stored on this volume.
    You may want to back it up every now and then.
* Exposed ports
  * `25565`: the default Minecraft port.
* Build-time arguments
  * `VERSION`: Minecraft version to build image for. Defaults to 1.16.1.

    The latest Paper build for the given version will be used for the image.
