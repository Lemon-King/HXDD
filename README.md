<a name="readme-top"></a>
<br />
<div align="center">
  <a href="https://github.com/Lemon-King/HXDD">
    <img src=".github/readme/icon.png" alt="Logo" width="80" height="80">
  </a>

<h2>HXDD</h2>
<div>A Heretic and Hexen Wad Merger</div>

  <p align="center">
    <br />
    <a href="https://www.doomworld.com/forum/topic/136255-hxdd-a-heretic-hexen-wad-merger-071-beta/"><strong>DOOMWORLD THREAD »</strong></a>
    <br />
    <br />
    <a href="https://github.com/Lemon-King/HXDD/issues">Report Bug</a>
    ·
    <a href="https://github.com/Lemon-King/HXDD/issues">Request Feature</a>
  </p>
</div>

<div align="center">

<a href="https://github.com/Lemon-King/HXDD/releases">![Releases](https://img.shields.io/github/v/release/Lemon-King/HXDD?logo=github)</a>
<a href="https://github.com/Lemon-King/HXDD/issues">![Issues](https://img.shields.io/github/issues/Lemon-King/HXDD.svg)</a>
<a href="https://github.com/Lemon-King/HXDD/blob/master/LICENSE.md">![MIT License](https://img.shields.io/github/license/Lemon-King/HXDD.svg)</a>

<a href="https://mtrop.github.io/DoomStruct/">![DoomStruct](https://img.shields.io/badge/DoomStruct-000063?style=for-the-badge&logoColor=white)</a>
<a href="https://github.com/google/gson">![Gson](https://img.shields.io/badge/Gson-000?style=for-the-badge&logo=google&logoColor=61DAFB)</a>
<br/>
<a href="https://openjdk.org/">![Java](https://img.shields.io/badge/java-%23ED8B00.svg?style=for-the-badge&logo=openjdk&logoColor=white)</a>
<a href="https://openjfx.io/">![Java](https://img.shields.io/badge/javafx-55889E.svg?style=for-the-badge&logo=openjdk&logoColor=white)</a>
<br/>
<a href="https://gluonhq.com/">![Gluon](https://img.shields.io/badge/gluon-0A6DB0?style=for-the-badge&logo=gluon&logoColor=white)</a>
<a href="https://www.graalvm.org/">![GRAALVM](https://img.shields.io/badge/GRAALVM-192229?style=for-the-badge&logo=graalvm&logoColor=61DAFB)</a><br/>
<a href="https://richwhitehouse.com/index.php?content=inc_projects.php&showproject=91">![NOESIS](https://img.shields.io/badge/NOESIS-ff6600?style=for-the-badge&logoColor=#ff6600)</a>

</div>

<br/>

**HXDD** takes everything from Heretic, Hexen and other games. Then arranges and converts them into a new GZDOOM compatible format, allowing you play them as if they were a single game.
There is a fair amount of code acting as glue to make everything functional - not to mention numerous (optional) added features.

This project is inspired by [WADSMOOSH](https://jp.itch.io/wadsmoosh) by JP LeBreton. Go check it out too.


<div align="center">
  <a href=".github/readme/hxdd_beta_072.png">
    <img src=".github/readme/hxdd_beta_072.png" alt="Logo" width="250" height="auto">
  </a>
</div>

## Gameplay Features

* **Unified Game & Episode Structure**<br/>Play Heretic, Hexen and Deathkings from one menu with any class from either game!
* **Hexen II Leveling**<br/>A highly expanded version of the leveling system found in Hexen II.
* **Selectable Armor Modes**<br/>Choose between Simple and AC, compatible with all characters from both games!
* **Mod Support via PlayerSheets**<br/>Allows for cross game pickups and actors and expanded PlayerClass definitions. PlayerSheets will allow your mod to support HXDD only features without needing to expand actors or make another version of your mod. Just create a new json under playersheets/<classname>.json and you're ready to start!

## Current Upcoming & Planned Features
* **Hexen II Classes**<br/>You can use many of the classes now in a **WORK IN PROGRESS** state. Upcoming updates focusing on these are next in the coming updates.
* **PWAD Mode**<br/>HXDD will build out to a slimmed DOOM compatible pwad, sometime during beta or post 1.0 release.
* **Heretic II Corvus**<br/>Currently in an [prototyping phase](https://www.youtube.com/watch?v=RV1bI9vbNs8), due to the amount of work required.

## Getting Started

A modern version of Windows or Wine on MacOS and Linux.

HXDD has a minimum version requirement with [GZDOOM 4.11+](https://zdoom.org/downloads), if you do not have it please download and update to it.

Download HXDD from [Releases](https://github.com/Lemon-King/HXDD/releases) and unzip it into its own folder.

## Usage

HXDD will need to make use of files from GZDOOM, Heretic, Hexen, Hexen's Expansion Deathkings, and optionally Hexen II.

1. Launch HXDD.exe
2. Select your GZDOOM Folder
3. Select your Heretic wad File (heretic.wad)
4. Select your Hexen wad File (hexen.wad)
5. Select your Hexen DeathKings wad file (hexdd.wad)
6. Choose the options you want to utilize - if any.
7. Click on Build HXDD and let it build hxdd.ipk3.
8. Copy hxdd.ipk3 where you keep your wads for GZDOOM.
9. Run GZDOOM and select HXDD.

Once you select locations for these files, HXDD will store these next time you run it.

## Hexen II Usage

When using Hexen II PAK files with HXDD you will need [Noesis by Rich Whitehouse](https://richwhitehouse.com/index.php?content=inc_projects.php&showproject=91).

Download and place the Noesis zip file in the same folder as HXDD's exe.

Select the PAK files in the application and ensure Enable Hexen II is checked.

HXDD will use Noesis to open PAK files and export model data for use with GZDOOM.

## Screenshots & Video
<a href="https://i.imgur.com/8W0VM5p.png">
<img src="https://i.imgur.com/8W0VM5pm.png" alt="Logo" width="475" height="auto">
</a>

<a href="https://i.imgur.com/WF0hGCv.jpg">
<img src="https://i.imgur.com/WF0hGCvm.jpg" alt="Logo" width="475" height="auto">
</a>

<a href="https://i.imgur.com/HY5b2YZ.jpg">
<img src="https://i.imgur.com/HY5b2YZm.jpg" alt="Logo" width="475" height="auto">
</a>

[![YOUTUBE DEMO VIDEO](https://img.youtube.com/vi/PTh_TbOPyPc/0.jpg)](https://www.youtube.com/watch?v=PTh_TbOPyPc)

## License

Distributed under the MIT License. See `LICENSE.md` for more information.

## Contact

Lemon King - [@lemonkingi](https://twitter.com/lemonkingi)

Doomworld Thread - [HXDD: A Heretic & Hexen WAD Merger](https://www.doomworld.com/forum/topic/136255-hxdd-a-heretic-hexen-wad-merger-071-beta/)

Project Link: [https://github.com/Lemon-King/HXDD](https://github.com/Lemon-King/HXDD)

<p align="right">(<a href="#readme-top">back to top</a>)</p>