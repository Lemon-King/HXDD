package lemon.hxdd.builder;

import net.mtrop.doom.WadEntry;
import net.mtrop.doom.WadFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class WadFileOrganizer {
    String gameid;
    WadFile wad;
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
            "SNDCURVE"
    };

    static String[] GameLumps = {
            "animdefs", "sndinfo", "sndseq"
    };

    static String[] TextLumps = {
            "win1msg", "win2msg", "win3msg",
            "clus1msg", "clus2msg", "clus3msg", "clus4msg"
    };

    static String[] GraphicLumps = {
        // MacOS files
        //"TITLE1", "TITLE2", "TITLE3", "TITLE4", "PRSGCRED",
        "ARTIBOX", "IN_X"
    };

    public WadFileOrganizer() {
        this.entryMaps = new HashMap<>();
        this.entryMaps.put("lumps", new HashMap<>());   // just raw lumps, must have folder set
        this.entryMaps.put("graphics", new HashMap<>());
        this.entryMaps.put("flats", new HashMap<>());
        this.entryMaps.put("patches", new HashMap<>());
        this.entryMaps.put("sprites", new HashMap<>());
        this.entryMaps.put("sounds", new HashMap<>());
        this.entryMaps.put("music", new HashMap<>());
    }

    public void SetWadFile(String gameid, WadFile wad) {
        this.gameid = gameid;
        this.wad = wad;
    }

    public void AddFile(MetaFile mf) {
        String type = mf.type;
        this.entryMaps.get(type).put(mf.inputName, mf);
    }

    public void Parse(String path) throws IOException {
        String source = this.wad.getFileAbsolutePath();

        String decodeType = "";
        String folder = "";
        for (WadEntry entry : this.wad) {
            String entryName = entry.getName();
            MetaFile mf = new MetaFile(this.gameid);
            mf.SetWad(this.wad);
            if (Arrays.asList(EngineLumps).contains(entryName)) {
                mf.Define(entryName, "lump","lumps", this.wad);
                this.entryMaps.get("lumps").put(entryName, mf);
            } else if (Arrays.asList(GameLumps).contains(entryName.toLowerCase())) {
                // Will let files be unique and not fight over a single entry.
                mf.Define(entryName, "lump","lumps", this.wad);
                this.entryMaps.get("lumps").put(entryName, mf);
            } else if (Arrays.asList(TextLumps).contains(entryName.toLowerCase())) {
                // TextLumps should be renamed per game as to prevent conflicts
                mf.Define(entryName, "textlump","lumps", this.wad);
                mf.outputName = entryName;
                this.entryMaps.get("lumps").put(entryName, mf);
            } else if (!Arrays.asList(EntryIgnoreList).contains(entryName)) {
                if (entry.isMarker()) {
                    if (entryName.contains("_START")) {
                        if (entryName.startsWith("S_")) {
                            decodeType = "sprite";
                            folder = "sprites";
                        } else if (entryName.startsWith("P")) {
                            decodeType = "patch";
                            folder = "patches";
                        } else if (entryName.startsWith("F")) {
                            decodeType = "flat";
                            folder = "flats";
                        }
                    } else if (!folder.equals("") && entryName.contains("_END")) {
                        decodeType = "";
                        folder = "";
                    }
                } else if (entryName.startsWith("FONT")) {
                    mf.Define(entryName, "graphic","graphics", this.wad);
                    this.entryMaps.get("graphics").put(entryName, mf);
                } else if (entryName.equals("ADVISOR")) {
                    // Heretic / Hexen only advisory
                    mf.Define(entryName, "sprite", "graphics", this.wad);
                    this.entryMaps.get("graphics").put(entryName, mf);
                } else if (Arrays.asList(GraphicLumps).contains(entryName) || folder.equals("graphics")) {
                    decodeType = "graphic";
                    folder = "graphics";
                    mf.Define(entryName, decodeType, folder, this.wad);
                    this.entryMaps.get(folder).put(entryName, mf);
                } else if (folder.equals("sprites") || folder.equals("patches") || folder.equals("flats")) {
                    mf.Define(entryName, decodeType, folder, this.wad);
                    this.entryMaps.get(folder).put(entryName, mf);
                } else {
                    try {
                        byte[] data = this.wad.getData(entry);
                        if (data.length > 4) {
                            // startswith is hacky, but it works
                            if ((data[0] + "" + data[1] + "" + data[2] + "" + data[3]).startsWith("778583")) {
                                mf.Define(entryName, "music","music", this.wad);
                                this.entryMaps.get("music").put(entryName, mf);
                            } else if ((data[0] + "" + data[1] + "" + data[2] + "" + data[3]).startsWith("301743")) {
                                mf.Define(entryName, "sound","sounds", this.wad);
                                this.entryMaps.get("sounds").put(entryName, mf);
                            }
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        //wadFile.close();
        System.out.println("Parsed assets from " + this.wad.getFileName());
    }

    public void MergeFrom(WadFileOrganizer from, String type) {
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

    public void MergeByMatch(WadFileOrganizer from, String type, String chars, String method) {
        from.entryMaps.get(type).forEach((key, entry) -> {
            if ((method.equals("startsWith") && entry.outputName.startsWith(chars)) ||
                    (method.equals("equals") && entry.outputName.equals(chars))) {
                this.entryMaps.get(type).put(key, entry);
            }
        });
    }

    public MetaFile CopyFile(String folder, String source, String target) {
        MetaFile mfFrom = this.entryMaps.get(folder).get(source);
        if (mfFrom != null) {
            MetaFile mfCopy = new MetaFile(this.gameid);
            mfCopy.Define(target, mfFrom.decodeType, folder, mfFrom.wad);
            mfCopy.SetWad(mfFrom.wad);
            //mfCopy.sourcePK3 = mfFrom.sourcePK3;
            mfCopy.inputName = mfFrom.inputName;
            mfCopy.folder = mfFrom.folder;
            mfCopy.decodeType = mfFrom.decodeType;
            this.entryMaps.get(folder).put(target, mfCopy);

            return mfCopy;
        }
        return null;
    }

    public void BatchRename(String type, String from, String to, String method) {
        HashMap<String, MetaFile> MetaFileChange = new HashMap<>();
        this.entryMaps.get(type).forEach((key, entry) -> {
            if ((method.equals("startsWith") && entry.inputName.startsWith(from)) ||
                    (method.equals("equals") && entry.inputName.equals(from))) {
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
            if ((method.equals("startsWith") && entry.inputName.startsWith(name)) ||
                    (method.equals("equals") && entry.inputName.equals(name))) {
                removalKeys.add(key);
            }
        });
        removalKeys.forEach((key) -> {
            this.entryMaps.get(type).remove(key);
        });
    }

    public void BatchSetTargetFolder(String type, String name, String target, String method) {
        HashMap<String, MetaFile> MetaFileChange = new HashMap<>();
        this.entryMaps.get(type).forEach((key, entry) -> {
            if ((method.equals("startsWith") && entry.inputName.startsWith(name)) ||
                    (method.equals("equals") && entry.inputName.equals(name))) {
                entry.folder = target;
                MetaFileChange.put(entry.inputName, entry);
            }
        });
        MetaFileChange.forEach((key, entry) -> {
            this.entryMaps.get(type).remove(entry.inputName);
            this.entryMaps.get(type).put(key, entry);
        });
    }
}
