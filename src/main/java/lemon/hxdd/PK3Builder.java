package lemon.hxdd;

import net.mtrop.doom.Wad;
import net.mtrop.doom.WadBuffer;
import net.mtrop.doom.WadFile;
import net.mtrop.doom.graphics.Palette;
import net.mtrop.doom.util.MapUtils;
import org.zeroturnaround.zip.NameMapper;
import org.zeroturnaround.zip.ZipUtil;
import org.zeroturnaround.zip.commons.FileUtils;

import java.io.*;
import java.net.URISyntaxException;
import java.util.*;

public class PK3Builder {
    static String[] iwadNames = {"heretic", "hexen", "hexdd"};
    static String[] requiredPK3s = {
            "gzdoom", "game_support"
    };
    static String[] optionalPK3s = {
            "brightmaps", "game_widescreen_gfx", "lights",
            // todo: Add neoworm frozen sprite support
    };

    public Map<String, FileOrganizer> organizedFiles;

    public PK3Builder() {
        this.organizedFiles = new HashMap<>();
    }

    public void Assemble() {
        if (HasRequiredFiles()) {
            CleanTemporaryFolder(); // if the folder exists, wipe it.
            ParseAssets();
            OrganizeAssets();
            FileOrganizer merged = MergeAssets();
            ExtractAssets(merged);
            ExtractFilesFromGZDoomSupportPK3s();
            ExportMaps();
            ActorFactory actors = new ActorFactory();
            actors.Create();
            actors.CreateEditorNums();
            ExportHXDDFiles();
            Bundle();
        }
    }

    private boolean HasRequiredFiles() {
        ArrayList<String> missingFiles = new ArrayList<String>();
        String pathSourceFiles = (String) Settings.getInstance().Get("PathSourceWads");
        Arrays.asList(iwadNames).forEach((wadName) -> {
            String fileName = pathSourceFiles + wadName + ".wad";
            File fileTemporary = new File(fileName);
            if (!fileTemporary.exists()) {
                missingFiles.add(wadName + ".wad");
            }
        });
        Arrays.asList(requiredPK3s).forEach((wadName) -> {
            String fileName = pathSourceFiles + wadName + ".pk3";
            File fileTemporary = new File(fileName);
            if (!fileTemporary.exists()) {
                missingFiles.add(wadName + ".pk3");
            }
        });
        if (missingFiles.size() > 0) {
            System.out.println("Cannot continue, missing the following files:");
            System.out.println(String.join(", ", missingFiles));
            return false;
        }
        return true;
    }

    private void ParseAssets() {
        Arrays.asList(iwadNames).forEach((wadName) -> {
            FileOrganizer woEntry = new FileOrganizer();
            try {
                woEntry.Parse(wadName);
                this.organizedFiles.put(wadName, woEntry);
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
    }

    private void OrganizeAssets() {
        System.out.println("Organizing assets");

        // Rename conflicting sprite names: https://zdoom.org/wiki/Sprite#Conflicting_sprite_names
        // Heretic
        this.organizedFiles.get("heretic").BatchRename("sprites", "BLOD", "BLUD", "startsWith");
        this.organizedFiles.get("heretic").BatchRename("sprites", "HEAD", "LICH", "startsWith");

        // Hexen (Follows order from: https://github.com/coelckers/gzdoom/blob/c1a8776a154d91657e7288df46855df932fcbf37/src/d_main.cpp#L2302)
        this.organizedFiles.get("hexen").BatchRename("sprites", "BARL", "ZBAR", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "ARM1", "AR_1", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "ARM2", "AR_2", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "ARM3", "AR_3", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "ARM4", "AR_4", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "SUIT", "ZSUI", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "TRE1", "ZTRE", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "TRE2", "TRES", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "CAND", "BCAN", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "ROCK", "ROKK", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "WATR", "HWAT", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "GIBS", "POL5", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "EGGM", "PRKM", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "INVU", "DEFN", "startsWith");
        this.organizedFiles.get("hexen").BatchRename("sprites", "ARTIINVU", "ARTIDEFN", "equals");

        this.organizedFiles.get("hexen").BatchRename("sprites", "MNTRF", "MNTRU", "equals");
        this.organizedFiles.get("hexen").BatchRename("sprites", "MNTRG", "MNTRV", "equals");
        this.organizedFiles.get("hexen").BatchRename("sprites", "MNTRH", "MNTRW", "equals");
        this.organizedFiles.get("hexen").BatchRename("sprites", "MNTRI", "MNTRX", "equals");
        this.organizedFiles.get("hexen").BatchRename("sprites", "MNTRJ", "MNTRY", "equals");
        this.organizedFiles.get("hexen").BatchRename("sprites", "MNTRK", "MNTRZ", "equals");

        // Rename cluster messages follow new cluster order
        this.organizedFiles.get("hexen").BatchRename("lumps", "CLUS1MSG", "CLUS7MSG", "equals");
        this.organizedFiles.get("hexen").BatchRename("lumps", "CLUS2MSG", "CLUS8MSG", "equals");
        this.organizedFiles.get("hexen").BatchRename("lumps", "CLUS3MSG", "CLUS9MSG", "equals");
        this.organizedFiles.get("hexen").BatchRename("lumps", "CLUS4MSG", "CLUS10MSG", "equals");
        this.organizedFiles.get("hexdd").BatchRename("lumps", "CLUS1MSG", "CLUS11MSG", "equals");
        this.organizedFiles.get("hexdd").BatchRename("lumps", "CLUS2MSG", "CLUS12MSG", "equals");

        this.organizedFiles.get("hexdd").BatchRename("lumps", "WIN1MSG", "WIN4MSG", "equals");
        this.organizedFiles.get("hexdd").BatchRename("lumps", "WIN2MSG", "WIN5MSG", "equals");
        this.organizedFiles.get("hexdd").BatchRename("lumps", "WIN3MSG", "WIN6MSG", "equals");

        // Remove Heretic Sky and copy Hexen Sky in its place.
        this.organizedFiles.get("heretic").BatchRemove("flats", "F_SKY1", "equals");
        this.organizedFiles.get("hexen").CopyFile("flats", "F_SKY", "F_SKY1");

        // Rename Hexen files which share names with Heretic which we want to use in HXDD.
        // For now, rule is if Hexen does share a filename with Heretic an X will be appended to that file.
        // Otherwise, remove the file from the merge list.
        this.organizedFiles.get("hexen").BatchRename("graphics", "M_HTIC", "M_HTICX", "equals");

        // Player sprite conflict fixes
        this.organizedFiles.get("hexen").BatchRename("sprites", "PLAY", "FIGH", "startsWith");      // Fighter Sprites
        this.organizedFiles.get("hexen").BatchRename("sprites", "FDTH", "FDHX", "startsWith");      // Fire Death Sprites
        this.organizedFiles.get("hexen").BatchRename("sprites", "CLER[0", "CLRFA0", "equals");       // cleric fix?
        this.organizedFiles.get("hexen").BatchRename("sprites", "CLER\\0", "CLRFB0", "equals");       // cleric fix?

        // Optional Hexen Egg Art (Gold), Set by CVar
        this.organizedFiles.get("hexen").BatchRename("sprites", "ARTIEGGC", "ARTIEGGX", "equals");
        //this.organizedFiles.get("hexen").BatchRename("sprites", "EGGM", "EGGX", "startsWith");

        // Rename Hexen skies, will be handled by script for MAP files
        this.organizedFiles.get("hexen").BatchRename("patches", "SKY1", "SKY1X", "equals");
        this.organizedFiles.get("hexen").BatchRename("patches", "SKY2", "SKY2X", "equals");
        this.organizedFiles.get("hexen").BatchRename("patches", "SKY3", "SKY3X", "equals");
        this.organizedFiles.get("hexen").BatchRename("patches", "WALL501", "WALL501X", "equals");   // shared patch name

        this.organizedFiles.get("hexen").BatchRename("graphics", "CHAIN", "CHAINX", "equals");

        this.organizedFiles.get("hexen").BatchRename("graphics", "FONTB", "FONTBX", "startsWith");  // Lets keep Hexen's big red font around

        // Other shared assets
        this.organizedFiles.get("hexen").BatchRemove("graphics", "PLAYPAL", "equals");
        this.organizedFiles.get("hexen").BatchRemove("graphics", "COLORMAP", "equals");
        this.organizedFiles.get("hexen").BatchRemove("graphics", "FONTA", "startsWith");
        this.organizedFiles.get("hexen").BatchRemove("graphics", "SMALLIN", "startsWith");
        this.organizedFiles.get("hexen").BatchRemove("graphics", "SMALLIN", "startsWith");
        this.organizedFiles.get("hexen").BatchRemove("graphics", "PAUSED", "equals");
        this.organizedFiles.get("hexen").BatchRemove("graphics", "ADVISOR", "equals");
        this.organizedFiles.get("hexen").BatchRemove("graphics", "M_SKL", "startsWith");
        this.organizedFiles.get("hexen").BatchRemove("graphics", "SELECTB0", "equals");
        this.organizedFiles.get("hexen").BatchRemove("graphics", "SPFLY", "startsWith");
    }

    private FileOrganizer MergeAssets() {
        // Takes organized wad / pk3 data and merges it into a single meta hashmap.
        System.out.println("Merging assets");
        FileOrganizer merged = new FileOrganizer();
        Arrays.asList(iwadNames).forEach((wadName) -> {
            FileOrganizer from = organizedFiles.get(wadName);
            merged.MergeFrom(from, "lumps");
            merged.MergeFrom(from, "flats");
            merged.MergeFrom(from, "graphics");
            merged.MergeFrom(from, "patches");
            merged.MergeFrom(from, "sprites");
            merged.MergeFrom(from, "sounds");
            merged.MergeFrom(from, "music");
        });

        return merged;
    }

    private void ExtractAssets(FileOrganizer fo) {
        // Extracts data from wads by identified type
        System.out.println("Extracting assets, this may take a few minutes");
        Map<String, WadFile> Wads = new HashMap<String, WadFile>();

        fo.entryMaps.forEach((sourceName, mftype) -> {
            System.out.println("Extracting " + sourceName);
            mftype.forEach((mfKey, mf) -> {
                //System.out.println(key + " " + mfKey + " " + mf.source + ":" + mf.inputName + ":" + mf.outputName);
                try {
                    if (!Wads.containsKey(mf.source)) {
                        String wadPath = (String) Settings.getInstance().Get("PathSourceWads");
                        Wads.put(mf.source, new WadFile(wadPath + mf.source + ".wad"));
                    };
                } catch (IOException e) {
                    // Failed to open wad
                    e.printStackTrace();
                }
                Wad w = Wads.get(mf.source);
                AssetExtractor ae = new AssetExtractor(mf, w);
                if (mf.sourcePK3 != null) {
                    ae.ExtractFromPK3();
                } else {
                    ae.ExtractFromWad();
                }
            });
        });

        Wads.forEach((key, wad) -> {
            try {
                wad.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
    }

    public void ExportMaps() {
        Arrays.asList(iwadNames).forEach((wadName) -> {
            try {
                String wadPath = (String) Settings.getInstance().Get("PathSourceWads");
                Wad wad = new WadFile(wadPath + wadName + ".wad");

                System.out.println("Exporting Maps from " + wadName + ".wad");
                String path = Settings.getInstance().Get("PathTemporary") + "/maps/";
                File dirFile = new File(path);
                if (!dirFile.exists()) {
                    dirFile.mkdirs();
                }

                String mapSetHeader = (String) Settings.getInstance().Get("MapNameHeader_" + wadName);

                for (int headerIndex : MapUtils.getAllMapIndices(wad)) {
                    String headerName = wad.getEntry(headerIndex).getName();
                    String mapPath = path + mapSetHeader + headerName + ".wad";
                    try {
                        WadBuffer.extract(wad, MapUtils.getMapEntries(wad, headerName)).writeToFile(new File(mapPath));
                        //System.out.println("Exported map " + headerName);
                    } catch (IOException e) {
                        System.out.println("Failed to export map " + headerName);
                    }
                }
                wad.close();

            } catch (IOException e) {
                e.printStackTrace();
            }
        });
    }

    // TODO: Move this mess into FileOrganizer.
    private static void ExtractFilesFromGZDoomSupportPK3s() {
        final int[] WidescreenGraphicDimensions = {560, 200};
        final String[] menuGraphics = new String[]{"final1.lmp", "final2.lmp", "help1.lmp", "help2.lmp", "mape1.lmp", "mape2.lmp", "mape3.lmp", "title.lmp"};
        final String pathSourceFiles = (String) Settings.getInstance().Get("PathSourceWads");

        System.out.println("Exporting GZDOOM assets");

        ZipAssets zipGZDoom = new ZipAssets("gzdoom.pk3");
        zipGZDoom.ExtractSingleFile("filter/game-heretic/sndinfo.txt", "sndinfo.hereticgz");
        zipGZDoom.ExtractSingleFile("filter/game-heretic/sndseq.txt", "sndseq.hereticgz");
        zipGZDoom.ExtractSingleFile("filter/game-heretic/animated.lmp", "animated.heretic");
        zipGZDoom.ExtractSingleFile("filter/game-hexen/sndinfo.txt", "sndinfo.hexengz");

        ZipAssets zipGameSupport = new ZipAssets("game_support.pk3");
        zipGameSupport.ExtractSingleFile("filter/heretic/sprofs.txt", "sprofs.heretic");
        zipGameSupport.ExtractSingleFile("filter/hexen/sprofs.txt", "sprofs.hexen");

        File fileLights = new File(pathSourceFiles + "lights.pk3");
        if (fileLights.exists()) {
            ZipAssets zipLights = new ZipAssets("lights.pk3");
            zipLights.ExtractSingleFile("filter/heretic/gldefs.txt", "gldefs.heretic");
            zipLights.ExtractSingleFile("filter/hexen/gldefs.txt", "gldefs.hexen");
        }

        File fileBrights = new File(pathSourceFiles + "lights.pk3");
        if (fileBrights.exists()) {
            ZipAssets zipBrights = new ZipAssets("brightmaps.pk3");
            zipBrights.ExtractSingleFile("filter/heretic/gldefs.bm", "gldefs.bmheretic");
            zipBrights.ExtractSingleFile("filter/hexen/gldefs.bm", "gldefs.bmhexen");
        }

        File fileWide = new File(pathSourceFiles + "lights.pk3");
        ZipAssets zipWide = null;
        if (fileWide.exists()) {
            zipWide = new ZipAssets("game_widescreen_gfx.pk3");
            zipWide.ExtractFilesFromFolderAndConvert("filter/heretic/sprites/", "sprites", "heretic", null, null);
            zipWide.ExtractFilesFromFolderAndConvert("filter/hexen/sprites/", "sprites", "hexen", null, null);

            zipWide.ExtractFilesFromFolderAndConvert("filter/heretic/graphics/", "graphics", "heretic", new String[]{"barback.lmp", "ltfctop.lmp", "rtfctop.lmp"}, null);
            zipWide.ExtractFilesFromFolderAndConvert("filter/hexen/graphics/", "graphics", "hexen", new String[]{"h2bar.lmp", "h2top.lmp"}, null);
            zipWide.ExtractFilesFromFolderAndConvert("filter/hexen/graphics/", "graphics", "hexen", new String[]{"interpic.lmp", "finale1.lmp", "finale2.lmp", "finale3.lmp"}, WidescreenGraphicDimensions);
        }

        // Title Selection, Heretic, Heretic Shadows, Hexen, or HexDD.
        // If extended entry exists in heretic.wad
        String menuTheme = (String) Settings.getInstance().Get("MenuTheme");
        if (menuTheme.equals("heretic") || menuTheme.equals("hereticclassic")) {
            if (zipWide != null) {
                zipWide.ExtractFilesFromFolderAndConvert("filter/heretic/graphics/", "graphics", "heretic", menuGraphics, WidescreenGraphicDimensions);
            }
            zipGameSupport.ExtractFilesFromFolderAndConvert("filter/game-heretic/fonts/defbigfont/", "fonts/defbigfont", "heretic", null, null);
            zipGameSupport.ExtractFilesFromFolderAndConvert("filter/game-heretic/fonts/defsmallfont/", "fonts/defsmallfont", "heretic", null, null);
        } else if (menuTheme.equals("hexen") || menuTheme.equals("hexdd")) {
            if (zipWide != null) {
                zipWide.ExtractFilesFromFolderAndConvert("filter/hexen/graphics/", "graphics", "hexen", menuGraphics, WidescreenGraphicDimensions);
            }
            zipGameSupport.ExtractFilesFromFolderAndConvert("filter/game-hexen/fonts/defbigfont/", "fonts/defbigfont", "hexen", null, null);
            zipGameSupport.ExtractFilesFromFolderAndConvert("filter/game-hexen/fonts/defsmallfont/", "fonts/defsmallfont", "hexen", null, null);
        }
    }

    private void ExportHXDDFiles() {
        System.out.println("Adding HXDD assets");
        String pathTemporary = (String) Settings.getInstance().Get("PathTemporary");
        try {
            String protocol = Objects.requireNonNull(this.getClass().getResource("")).getProtocol();    // are we running from IDE?
            if (protocol.equals("jar")){
                final String prefix = "assets/";
                File jarHXDD = new File(lemon.hxdd.Application.class.getProtectionDomain().getCodeSource().getLocation().toURI());
                ZipUtil.unpack(jarHXDD, new File(pathTemporary), new NameMapper() {
                    public String map(String name) {
                        if (name.startsWith(prefix)) {
                            return name.startsWith(prefix) ? name.substring(prefix.length()) : name;
                        } else {
                            return null;
                        }
                    }
                });
            } else if (protocol.equals("file")) {
                FileUtils.copyDirectory(new File("./src/main/resources/assets"), new File(pathTemporary));
            } else {
                System.out.println("Failed to export HXDD Assets.");
            }
        } catch (IOException | URISyntaxException e) {
            e.printStackTrace();
        }
    }

    private void Bundle() {
        System.out.println("Packing HXDD.ipk3");
        String path = (String) Settings.getInstance().Get("PathTemporary");
        File fileTemporary = new File(path);
        ZipUtil.pack(fileTemporary, new File("./HXDD.ipk3"), new NameMapper() {
            public String map(String name) {
                return name;
            }
        });
        CreateHexenPalettePK3();
        try {
            System.out.println("Cleaning up temporary data");
            FileUtils.deleteDirectory(fileTemporary);
            System.out.println("\nComplete! Copy HXDD.ipk3 to your GZDOOM wad folder and select it from the start menu!");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void CleanTemporaryFolder() {
        try {
            String pathTemporary = (String) Settings.getInstance().Get("PathTemporary");
            File fileTemporary = new File(pathTemporary);
            if (fileTemporary.exists()) {
                FileUtils.cleanDirectory(fileTemporary);
            }
        } catch (IOException e) {
            //e.printStackTrace();
        }
    }

    // Create Hexen focused palette PK3 for wads using palette textures
    private void CreateHexenPalettePK3() {
        String pathSourceFiles = (String) Settings.getInstance().Get("PathSourceWads");
        try {
            WadFile wadFile = new WadFile(pathSourceFiles + "hexen.wad");
            Palette pal = wadFile.getDataAs("playpal", Palette.class);
            File pk3File = new File("./hxdd_hexen_palette.pk3");
            ZipUtil.createEmpty(pk3File);
            ZipUtil.addEntry(pk3File, "PLAYPAL.lmp", pal.toBytes());
            wadFile.close();
            System.out.println("Created Hexen Palette PK3");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
