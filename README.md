
HXDD: A Heretic and Hexen Wad Merging Tool
=======

HXDD creates a singular ipk3 from Heretic and Hexen's iWADs.
You'll find all four classes, Heretic's Episodes, Hexen, and DeathKings of the Dark Citadel are all available in episode selection.

### Required Software
* Java
* A copy of Heretic, Hexen, DeathKings, and GZDoom

### Usage
From the folder you have HXDD.jar unzipped to, copy the following files into the folder named **wads**.
* heretic.wad
* hexen.wad
* hexdd.wad
* brightmaps.pk3
* game_support.pk3
* game_widescreen_gfx.pk3
* gzdoom.pk3

All that's left is to run HXDD.jar, if your Java install is associated with jar files:

You also can run it by command line too:
```shell
java -jar hxdd.jar
```
HXDD will begin cataloguing the assets and organizing everything that is required to create the iPK3.
This make take a few minutes as some assets need to be processed and converted to another format to ensure
compatibility between games.

GZDoom's pk3 assets are also processed too, due to filtering rules between Heretic and Hexen.

Once complete copy the result **HXXD.ipk3** to your GZDoom iwad folder.

### Libraries
HXDD makes use of [DoomStruct](https://github.com/MTrop/DoomStruct) by Mtrop and [zt-zip](https://github.com/zeroturnaround/zt-zip) by ZeroTurnaround.