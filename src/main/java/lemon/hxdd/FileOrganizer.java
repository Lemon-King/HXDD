package lemon.hxdd;

import net.mtrop.doom.WadEntry;
import net.mtrop.doom.WadFile;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

class FileOrganizer {
    public Map<String, Map<String, MetaFile>> entryMaps;

    // Maps get extracted separately
    static String[] EntryIgnoreList = {
            "THINGS", "LINEDEFS","SIDEDEFS","VERTEXES",
            "SEGS", "SSECTORS","NODES","SECTORS",
            "REJECT", "BLOCKMAP", "BEHAVIOR",
            "PNAMES", "TEXTURE1", "TEXTURE2"
    };

    static String[] EngineLumps = {
            "STARTUP", "PLAYPAL", "EXTENDED",
            "COLORMAP",  "FOGMAP", "TINTTAB",
    };

    static String[] GameLumps = {
            "animdefs", "sndinfo", "sndseq",
            "win1msg", "win2msg", "win3msg",
            "clus1msg", "clus2msg", "clus3msg", "clus4msg"
    };

    public FileOrganizer() {
        this.entryMaps = new HashMap<>();
        this.entryMaps.put("lumps", new HashMap<>());   // just raw lumps, must have folder set
        this.entryMaps.put("graphics", new HashMap<>());
        this.entryMaps.put("flats", new HashMap<>());
        this.entryMaps.put("patches", new HashMap<>());
        this.entryMaps.put("sprites", new HashMap<>());
        this.entryMaps.put("sounds", new HashMap<>());
        this.entryMaps.put("music", new HashMap<>());
    }

    public void AddFile(MetaFile mf) {
        String type = mf.type;
        this.entryMaps.get(type).put(mf.inputName, mf);
    }

    public void Parse(String wadName) throws IOException {
        WadFile wadFile = null;
        try {
            String wadPath = (String) Settings.getInstance().Get("PathSourceWads");
            wadFile = new WadFile(wadPath + wadName + ".wad");
        } catch (IOException e) {
            e.printStackTrace();
        }

        String type = "";
        for (WadEntry entry : wadFile) {
            String entryName = entry.getName();
            if (Arrays.asList(EngineLumps).contains(entryName)) {
                this.entryMaps.get("lumps").put(entryName, new MetaFile(entryName, "lumps", wadName));
            } else if (Arrays.asList(GameLumps).contains(entryName.toLowerCase())) {
                // This will let files be unique and not fight over a single entry.
                MetaFile mf = new MetaFile(entryName, "lumps", wadName);
                mf.decodeType = "lumps";
                mf.outputName = entryName + "." + wadName;
                this.entryMaps.get("lumps").put(entryName + "." + wadName, mf);
            } else if (!Arrays.asList(EntryIgnoreList).contains(entryName)) {
                if (entry.isMarker()) {
                    if (entryName.contains("_START")) {
                        if (entryName.startsWith("S_")) {
                            type = "sprites";
                        } else if (entryName.startsWith("P")) {
                            type = "patches";
                        } else if (entryName.startsWith("F")) {
                            type = "flats";
                        }
                    } else if (!type.equals("") && entryName.contains("_END")) {
                        type = "";
                    }
                } else if (entryName.startsWith("FONT")) {
                    this.entryMaps.get("graphics").put(entryName, new MetaFile(entryName, "graphics", wadName));
                } else if (entryName.equals("ADVISOR")) {
                    // Heretic / Hexen only advisory
                    String advisorType = "graphics";
                    MetaFile mf = new MetaFile(entryName, advisorType, wadName);
                    mf.decodeType = "sprites";
                    this.entryMaps.get(advisorType).put(entryName, mf);
                } else if (entryName.equals("IN_X") || entryName.equals("ARTIBOX") || type.equals("graphics")) {
                    type = "graphics";
                    this.entryMaps.get(type).put(entryName, new MetaFile(entryName, type, wadName));
                } else if (type.equals("sprites") || type.equals("patches") || type.equals("flats")) {
                    this.entryMaps.get(type).put(entryName, new MetaFile(entryName, type, wadName));
                } else {
                    try {
                        byte[] data = wadFile.getData(entry);
                        if (data.length > 4) {
                            // startswith is hacky, but it works
                            if ((data[0] + "" + data[1] + "" + data[2] + "" + data[3]).startsWith("778583")) {
                                this.entryMaps.get("music").put(entryName, new MetaFile(entryName, "music", wadName));
                            } else if ((data[0] + "" + data[1] + "" + data[2] + "" + data[3]).startsWith("301743")) {
                                this.entryMaps.get("sounds").put(entryName, new MetaFile(entryName, "sounds", wadName));
                            }
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        wadFile.close();
        System.out.println("Parsed assets from " + wadName + ".wad");
    }

    public void MergeFrom(FileOrganizer from, String type) {
        from.entryMaps.get(type).forEach((key, fromFile) -> {
            MetaFile to = this.entryMaps.get(type).get(key);
            if (to != null) {
                if (to.outputName.equals(fromFile.outputName)) {
                    //System.out.println("File Entry Exists, cannot merge. Current = [" + to.source + ":" + to.folder + ":" + to.outputName + "] Copy From = [" + fromFile.source + ":" + fromFile.folder + ":" + fromFile.outputName + "]");
                } else {
                    this.entryMaps.get(type).put(key, fromFile);
                }
            } else {
                this.entryMaps.get(type).put(key, fromFile);
            }
        });
    }

    public void MergeByMatch(FileOrganizer woFrom, String type, String chars, String method) {
        woFrom.entryMaps.get(type).forEach((key, entry) -> {
            if ((method == "startsWith" && entry.outputName.startsWith(chars)) ||
                    (method == "equals" && entry.outputName.equals(chars))) {
                this.entryMaps.get(type).put(key, entry);
            }
        });
    }

    public void CopyFile(String type, String source, String target) {
        MetaFile mfFrom = this.entryMaps.get(type).get(source);
        if (mfFrom != null) {
            MetaFile mfCopy = new MetaFile(target, type, mfFrom.source);
            mfCopy.sourcePK3 = mfFrom.sourcePK3;
            mfCopy.inputName = mfFrom.inputName;
            mfCopy.folder = mfFrom.folder;
            mfCopy.decodeType = mfFrom.decodeType;
            this.entryMaps.get(type).put(target, mfCopy);
        }
    }

    public void BatchRename(String type, String from, String to, String method) {
        HashMap<String, MetaFile> MetaFileChange = new HashMap<>();
        this.entryMaps.get(type).forEach((key, entry) -> {
            if ((method == "startsWith" && entry.inputName.startsWith(from)) ||
                    (method == "equals" && entry.inputName.equals(from))) {
                entry.outputName = entry.inputName.replace(from, to);
                MetaFileChange.put(entry.outputName, entry);
            }
        });
        MetaFileChange.forEach((key, entry) -> {
            this.entryMaps.get(type).remove(entry.inputName);
            this.entryMaps.get(type).put(key, entry);
        });
    }

    public void BatchRemove(String type, String name, String method) {
        ArrayList<String> removalKeys = new ArrayList<>();
        this.entryMaps.get(type).forEach((key, entry) -> {
            if ((method == "startsWith" && entry.inputName.startsWith(name)) ||
                    (method == "equals" && entry.inputName.equals(name))) {
                removalKeys.add(key);
            }
        });
        removalKeys.forEach((key) -> {
            this.entryMaps.get(type).remove(key);
        });
    }
}
