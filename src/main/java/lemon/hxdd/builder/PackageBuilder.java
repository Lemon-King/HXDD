package lemon.hxdd.builder;

import javafx.util.Pair;
import lemon.hxdd.Application;
import lemon.hxdd.shared.GITVersion;
import lemon.hxdd.shared.PAKTest;
import lemon.hxdd.shared.Util;
import net.mtrop.doom.Wad;
import net.mtrop.doom.WadBuffer;
import net.mtrop.doom.WadFile;
import net.mtrop.doom.graphics.Palette;
import net.mtrop.doom.util.GraphicUtils;
import net.mtrop.doom.util.MapUtils;
import org.zeroturnaround.zip.NameMapper;
import org.zeroturnaround.zip.ZipEntryCallback;
import org.zeroturnaround.zip.ZipUtil;
import org.zeroturnaround.zip.commons.FileUtils;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.*;
import java.io.*;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.zip.ZipEntry;

import static java.nio.file.StandardCopyOption.REPLACE_EXISTING;

public class PackageBuilder implements Runnable {
    Application app;

    public Map<String, WadFileOrganizer> organized = new HashMap<>();

    private ArrayList<Pair<String, WadFile>> wads = new ArrayList<>();
    private ArrayList<Pair<Integer, File>> paks = new ArrayList<>();

    private AssetExtractor ae;


    // local variables
    boolean hideAdvisory = false;


    public PackageBuilder(Application parent) {
        this.app = parent;

        this.ae = new AssetExtractor(this.app);
    }

    @Override
    public void run() {
        this.Start();
    }


    public void Start() {
        this.app.controller.SetCurrentProgress(0);

        try {
            wads.add(new Pair<>("heretic", new WadFile(this.app.settings.Get("PATH_HERETIC"))));
            wads.add(new Pair<>("hexen", new WadFile(this.app.settings.Get("PATH_HEXEN"))));
            wads.add(new Pair<>("hexdd", new WadFile(this.app.settings.Get("PATH_HEXDD"))));


            for (int i = 0; i < 5; i++) {
                String key = String.format("PATH_HEXENII_PAK%d", i);
                String path = this.app.settings.Get(key);
                if (!path.equals("")) {
                    paks.add(new Pair<>(i, new File(path)));
                }
            }

            this.app.controller.SetCurrentLabel("Preparing");
            this.app.controller.SetCurrentProgress(-1);
            CleanFolder(this.app.settings.GetPath("temp"));
            CleanFolder(this.app.settings.GetPath("hexen2"));

            ParseAssets();
            OrganizeAssets();
            ExtractAssets();
            ExportMaps();


            GameActorNums af = new GameActorNums(this.app.settings.GetPath("temp"));
            af.Create();

            //
            // HEXEN II EXPORT
            //
            // If Hexen II PAKs are found then try to export data
            String OPTION_USE_HX2 = this.app.settings.Get("OPTION_ENABLE_HX2");
            if ("true".equals(OPTION_USE_HX2) && HasPAKFiles(new String[]{this.app.settings.Get("PATH_HEXENII_PAK0"), this.app.settings.Get("PATH_HEXENII_PAK1")})) {
                // If Noesis zip or folder with exe is found, try Hexen 2 paks
                if (Noesis.CheckAndInstall()) {
                    String owned = "base";
                    if (HasPAKFiles(new String[]{this.app.settings.Get("PATH_HEXENII_PAK3")})) {
                        // Set World flag
                        owned = String.format("%s,portals", owned);
                    }
                    if (HasPAKFiles(new String[]{this.app.settings.Get("PATH_HEXENII_PAK4")})) {
                        // Set Portals flag
                        owned = String.format("%s,world", owned);
                    }
                    WriteHexen2InstallCVAR(owned);

                    Hexen2Assets h2a = new Hexen2Assets(this.app);
                    h2a.ExtractPakData();
                    h2a.ExportAssets();
                    h2a.ExportSounds();
                    h2a.ExportMusic();

                    XMLModelDef xmd = new XMLModelDef(this.app);
                    xmd.Generate();

                    SoundInfo si = new SoundInfo(this.app);
                    si.Export();
                }
            }

            ExtractFilesFromGZDoom();
            FixPatches();
            DownloadSteamArtwork();
            DownloadKoraxLocalization();

            ExportHXDDFiles();
            ApplyUserOptions();

            WriteInstallLanguageLookup();

            CreateHexenPalettePK3();

            Bundle();

            this.wads.forEach((p) -> {
                try {
                    p.getValue().close();
                } catch (IOException e) {
                    //
                }
            });

        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private void ParseAssets() {
        this.app.controller.SetStageLabel("Parsing Assets");
        AtomicInteger idx = new AtomicInteger();
        this.wads.forEach((p) -> {
            WadFileOrganizer wfo = new WadFileOrganizer();
            wfo.SetWadFile(p.getValue());
            try {
                wfo.Parse(p.getValue().getFileAbsolutePath());
                this.organized.put(p.getKey(), wfo);
                this.app.controller.SetCurrentLabel(p.getValue().getFileAbsolutePath());
                this.app.controller.SetCurrentProgress((double) idx.get() / this.wads.size());
            } catch (IOException e) {
                e.printStackTrace();
            }
            idx.getAndIncrement();
        });
    }

    private void OrganizeAssets() {
        System.out.println("Organizing asset tables");
        this.app.controller.SetCurrentLabel("");
        this.app.controller.SetCurrentProgress(-1.0);
        this.app.controller.SetStageLabel("Organizing Asset Tables");

        // Rename conflicting sprite names: https://zdoom.org/wiki/Sprite#Conflicting_sprite_names
        // Heretic
        this.organized.get("heretic").BatchRename("sprites", "BLOD", "BLUD", "startsWith");
        this.organized.get("heretic").BatchRename("sprites", "HEAD", "LICH", "startsWith");

        // Hexen (Follows order from: https://github.com/coelckers/gzdoom/blob/c1a8776a154d91657e7288df46855df932fcbf37/src/d_main.cpp#L2302)
        this.organized.get("hexen").BatchRename("sprites", "BARL", "ZBAR", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "ARM1", "AR_1", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "ARM2", "AR_2", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "ARM3", "AR_3", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "ARM4", "AR_4", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "SUIT", "ZSUI", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "TRE1", "ZTRE", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "TRE2", "TRES", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "CAND", "BCAN", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "ROCK", "ROKK", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "WATR", "HWAT", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "GIBS", "POL5", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "EGGM", "PRKM", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "INVU", "DEFN", "startsWith");
        this.organized.get("hexen").BatchRename("sprites", "ARTIINVU", "ARTIDEFN", "equals");

        this.organized.get("hexen").BatchRename("sprites", "MNTRF", "MNTRU", "equals");
        this.organized.get("hexen").BatchRename("sprites", "MNTRG", "MNTRV", "equals");
        this.organized.get("hexen").BatchRename("sprites", "MNTRH", "MNTRW", "equals");
        this.organized.get("hexen").BatchRename("sprites", "MNTRI", "MNTRX", "equals");
        this.organized.get("hexen").BatchRename("sprites", "MNTRJ", "MNTRY", "equals");
        this.organized.get("hexen").BatchRename("sprites", "MNTRK", "MNTRZ", "equals");

        // Rename cluster messages follow new cluster order
        this.organized.get("hexen").BatchRename("lumps", "CLUS1MSG", "CLUS7MSG", "equals");
        this.organized.get("hexen").BatchRename("lumps", "CLUS2MSG", "CLUS8MSG", "equals");
        this.organized.get("hexen").BatchRename("lumps", "CLUS3MSG", "CLUS9MSG", "equals");
        this.organized.get("hexen").BatchRename("lumps", "CLUS4MSG", "CLUS10MSG", "equals");
        this.organized.get("hexdd").BatchRename("lumps", "CLUS1MSG", "CLUS11MSG", "equals");
        this.organized.get("hexdd").BatchRename("lumps", "CLUS2MSG", "CLUS12MSG", "equals");

        this.organized.get("hexdd").BatchRename("lumps", "WIN1MSG", "WIN4MSG", "equals");
        this.organized.get("hexdd").BatchRename("lumps", "WIN2MSG", "WIN5MSG", "equals");
        this.organized.get("hexdd").BatchRename("lumps", "WIN3MSG", "WIN6MSG", "equals");

        // Remove Heretic Sky and copy Hexen Sky in its place.
        this.organized.get("heretic").BatchRemove("flats", "F_SKY1", "equals");
        this.organized.get("hexen").CopyFile("flats", "F_SKY", "F_SKY1");

        // Rename Hexen files which share names with Heretic which we want to use in HXDD.
        // For now, rule is if Hexen does share a filename with Heretic an X will be appended to that file.
        // Otherwise, remove the file from the merge list.
        this.organized.get("hexen").BatchRename("graphics", "M_HTIC", "M_HTICX", "equals");

        // Player sprite conflict fixes
        this.organized.get("hexen").BatchRename("sprites", "PLAY", "FIGH", "startsWith");      // Fighter Sprites
        this.organized.get("hexen").BatchRename("sprites", "FDTH", "FDHX", "startsWith");      // Fire Death Sprites
        this.organized.get("hexen").BatchRename("sprites", "CLER[0", "CLRFA0", "equals");      // cleric fix?
        this.organized.get("hexen").BatchRename("sprites", "CLER\\0", "CLRFB0", "equals");     // cleric fix?

        // Optional Hexen Egg Art (Gold), Set by CVar
        this.organized.get("hexen").BatchRename("sprites", "ARTIEGGC", "ARTIEGGX", "equals");
        //this.organized.get("hexen").BatchRename("sprites", "EGGM", "EGGX", "startsWith");

        // Rename Hexen skies, will be handled by script for MAP files
        this.organized.get("hexen").BatchRename("patches", "SKY1", "SKY1X", "equals");
        this.organized.get("hexen").BatchRename("patches", "SKY2", "SKY2X", "equals");
        this.organized.get("hexen").BatchRename("patches", "SKY3", "SKY3X", "equals");
        this.organized.get("hexen").BatchRename("patches", "WALL501", "WALL501X", "equals");   // shared patch name

        this.organized.get("hexen").BatchRename("graphics", "CHAIN", "CHAINX", "equals");

        this.organized.get("hexen").BatchRename("graphics", "FONTB", "FONTBX", "startsWith");  // Lets keep Hexen's big red font around

        this.organized.get("hexen").BatchRename("graphics", "CHAIN", "CHAIN1", "equals");
        this.organized.get("hexen").BatchRename("graphics", "STATBAR", "STATBARX", "equals");

        // Other shared assets
        this.organized.get("hexen").BatchRemove("graphics", "PLAYPAL", "equals");
        this.organized.get("hexen").BatchRemove("graphics", "COLORMAP", "equals");
        this.organized.get("hexen").BatchRemove("graphics", "FONTA", "startsWith");
        this.organized.get("hexen").BatchRemove("graphics", "SMALLIN", "startsWith");
        this.organized.get("hexen").BatchRemove("graphics", "SMALLIN", "startsWith");
        this.organized.get("hexen").BatchRemove("graphics", "PAUSED", "equals");
        this.organized.get("hexen").BatchRemove("graphics", "ADVISOR", "equals");
        this.organized.get("hexen").BatchRemove("graphics", "M_SKL", "startsWith");
        this.organized.get("hexen").BatchRemove("graphics", "SELECTB0", "equals");
        this.organized.get("hexen").BatchRemove("graphics", "SPFLY", "startsWith");
        this.organized.get("hexen").BatchRemove("lumps", "SNDSEQ", "equals");                 // patched version in resources

        this.organized.get("heretic").BatchRemove("graphics", "title", "equals");
        this.organized.get("hexen").BatchRemove("graphics", "title", "equals");

        // Hexen MacOS Unique Lumps
        this.organized.get("hexen").BatchRemove("lumps", "TITLE1", "equals");
        this.organized.get("hexen").BatchRemove("lumps", "TITLE2", "equals");
        this.organized.get("hexen").BatchRemove("lumps", "TITLE3", "equals");
        this.organized.get("hexen").BatchRemove("lumps", "TITLE4", "equals");
        this.organized.get("hexen").BatchRemove("lumps", "PRSGCRED", "equals");
    }


    private WadFileOrganizer MergeAssets() {
        // Takes organized wad / pk3 data and merges it into a single meta hashmap.
        System.out.println("Merging asset tables");
        this.app.controller.SetStageLabel("Merging Asset Tables");

        WadFileOrganizer merged = new WadFileOrganizer();
        this.wads.forEach((p) -> {
            WadFileOrganizer from = organized.get(p.getKey());
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

    private void ExtractAssets() {
        WadFileOrganizer merged = MergeAssets();

        // Extracts data from archives
        System.out.println("Extracting assets, this may take a few minutes");

        this.app.controller.SetCurrentLabel("");
        this.app.controller.SetCurrentProgress(0);
        this.app.controller.SetStageLabel("Extracting assets, this may take a few minutes");

        merged.entryMaps.forEach((sourceName, mftype) -> {
            int total = mftype.size();
            AtomicInteger count = new AtomicInteger();

            mftype.forEach((key, mf) -> {
                mf.ExtractFile(this.app.settings.GetPath("temp"));
                this.app.controller.SetCurrentLabel(mf.decodeType.toUpperCase() + ": " + mf.outputName);
                this.app.controller.SetCurrentProgress((float)count.incrementAndGet() / (float)total);
            });
        });
    }

    public void ExportMaps() {
        this.app.controller.SetCurrentProgress(0);
        this.wads.forEach((p) -> {
            Wad wad = p.getValue();
            String name = p.getKey();

            System.out.println("Exporting Maps from " + name + ".wad");
            String path = this.app.settings.GetPath("temp") + "/maps/";
            File dirFile = new File(path);
            if (!dirFile.exists()) {
                dirFile.mkdirs();
            }

            int[] indic = MapUtils.getAllMapIndices(wad);
            AtomicInteger count = new AtomicInteger();
            for (int idx : indic) {
                String mapName = wad.getEntry(idx).getName();
                String mapPathName = mapName;
                // HEXDD Expansion Hack, offset map number by 9
                // This offset is chosen as the last used map index starting at 42
                if (name.equals("hexdd")) {
                    int mapOffset = 9;
                    mapPathName = "MAP" + (Integer.parseInt(mapName.substring(3,5)) + mapOffset);
                }
                String mapPath = path + mapPathName + ".wad";
                this.app.controller.SetCurrentLabel(name + ".wad:" + mapPathName);
                try {
                    WadBuffer.extract(wad, MapUtils.getMapEntries(wad, mapName)).writeToFile(new File(mapPath));
                    //System.out.println("Exported map " + mapName);
                } catch (IOException e) {
                    System.out.println("Failed to export map " + mapName);
                }
                this.app.controller.SetCurrentProgress((float)count.incrementAndGet() / (float)indic.length);
            }

        });
    }

    private void FixPatches() {
        String pathTemporary = this.app.settings.GetPath("temp");

        // Fix any busted Patches due to export bugs
        //String[] hexenSkyPatches = {"SKYFOG2", "SKYWALL", "SKYWALL2"};
        ArrayList<Pair<String, Color[]>> colorSwap = new ArrayList<>();
        colorSwap.add(new Pair<>("patches/SKYFOG2.png", new Color[]{new Color(2, 2, 2, 255), new Color(0, 0, 0, 0)}));
        colorSwap.add(new Pair<>("patches/SKYWALL.png", new Color[]{new Color(2, 2, 2, 255), new Color(0, 0, 0, 0)}));
        colorSwap.add(new Pair<>("patches/SKYWALL2.png", new Color[]{new Color(2, 2, 2, 255), new Color(0, 0, 0, 0)}));
        colorSwap.add(new Pair<>("graphics/finale1.png", new Color[]{new Color(0, 0, 0, 0), new Color(0, 0, 0, 255)}));
        colorSwap.add(new Pair<>("graphics/finale2.png", new Color[]{new Color(0, 0, 0, 0), new Color(0, 0, 0, 255)}));
        colorSwap.add(new Pair<>("graphics/finale3.png", new Color[]{new Color(0, 0, 0, 0), new Color(0, 0, 0, 255)}));

        this.app.controller.SetCurrentLabel("Fixing Hexen Assets");
        this.app.controller.SetCurrentProgress(0);
        float count = 0;
        for (Pair<String, Color[]> set : colorSwap) {
            String path = String.format("%s/%s", pathTemporary, set.getKey());
            PostProcessImageData(path, set.getValue()[0], set.getValue()[1]);
            this.app.controller.SetCurrentProgress(++count / (float)colorSwap.size());
        }
    }

    private void ExtractFilesFromGZDoom() {
        final String[] menuGraphics = new String[]{"final1.lmp", "final2.lmp", "help1.lmp", "help2.lmp", "mape1.lmp", "mape2.lmp", "mape3.lmp", "title.lmp"};
        String pathSources = this.app.settings.Get("PATH_GZDOOM");

        System.out.println("Exporting GZDOOM assets");
        this.app.controller.SetCurrentLabel("Exporting GZDOOM Assets");
        this.app.controller.SetCurrentProgress(-1);

        File zipFile = new File(pathSources + "/gzdoom.pk3");
        if (zipFile.exists()) {
            ZipAssets za = new ZipAssets(this.app);
            za.SetFile(zipFile);
            za.ExtractSingleFile("filter/game-heretic/sndinfo.txt", "sndinfo.hereticgz");
            za.ExtractSingleFile("filter/game-heretic/sndseq.txt", "sndseq.hereticgz");
            za.ExtractSingleFile("filter/game-heretic/animated.lmp", "animated.heretic");
            za.ExtractSingleFile("filter/game-hexen/sndinfo.txt", "sndinfo.hexengz");
        }

        zipFile = new File(pathSources + "/game_support.pk3");
        if (zipFile.exists()) {
            ZipAssets za = new ZipAssets(this.app);
            za.SetFile(zipFile);
            za.ExtractSingleFile("filter/heretic/sprofs.txt", "sprofs.heretic");
            za.ExtractSingleFile("filter/hexen/sprofs.txt", "sprofs.hexen");
        }

        zipFile = new File(pathSources + "/lights.pk3");
        if (zipFile.exists()) {
            ZipAssets za = new ZipAssets(this.app);
            za.SetFile(zipFile);
            za.ExtractSingleFile("filter/heretic/gldefs.txt", "gldefs.heretic");
            za.ExtractSingleFile("filter/hexen/gldefs.txt", "gldefs.hexen");
        }

        zipFile = new File(pathSources + "/brightmaps.pk3");
        if (zipFile.exists()) {
            ZipAssets za = new ZipAssets(this.app);
            za.SetFile(zipFile);
            za.ExtractSingleFile("filter/heretic/gldefs.bm", "gldefs.bmheretic");
            za.ExtractSingleFile("filter/hexen/gldefs.bm", "gldefs.bmhexen");
        }

        zipFile = new File(pathSources + "/game_widescreen_gfx.pk3");
        if (zipFile.exists()) {
            final int[] WidescreenGraphicDimensions = {560, 200};

            ZipAssets za = new ZipAssets(this.app);
            za.SetFile(zipFile);
            za.ExtractFilesFromFolderAndConvert("filter/heretic/sprites/", "sprites", null, null);
            za.ExtractFilesFromFolderAndConvert("filter/hexen/sprites/", "sprites", null, null);

            za.ExtractFilesFromFolderAndConvert("filter/heretic/graphics/", "graphics",  new String[]{"barback.lmp", "ltfctop.lmp", "rtfctop.lmp"}, null);
            za.ExtractFilesFromFolderAndConvert("filter/hexen/graphics/", "graphics",  new String[]{"h2bar.lmp", "h2top.lmp"}, null);
            za.ExtractFilesFromFolderAndConvert("filter/hexen/graphics/", "graphics", new String[]{"interpic.lmp", "finale1.lmp", "finale2.lmp", "finale3.lmp"}, WidescreenGraphicDimensions);

            String OPTION_ARTWORK = this.app.settings.Get("OPTION_TITLE_ARTWORK");
            if ("random".equals(OPTION_ARTWORK)) {
                String[] list = {
                        "heretic", "heretic.shadow",
                        "hexen", "hexen.deathkings"
                };
                OPTION_ARTWORK = list[(int) Math.floor(Math.random() * list.length)];
            }
            String pathTitleArtwork = String.format("filter/%s/graphics/", OPTION_ARTWORK);
            if (pathTitleArtwork != null) {
                za.ExtractFilesFromFolderAndConvert(pathTitleArtwork, "graphics", new String[]{"title.lmp"}, WidescreenGraphicDimensions);
            }

            // Copy Hexen's interpic for conback.png
            String path = this.app.settings.GetPath("temp") + "/graphics/";
            File source = new File(path + "interpic.png");
            File dest = new File(path + "conback.png");
            if (source.exists()) {
                try {
                    FileUtils.copyFile(source, dest);
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }
        }
    }

    private void DownloadSteamArtwork() {
        this.app.controller.SetStageLabel("Title Artwork");
        this.app.controller.SetCurrentLabel("Checking");
        this.app.controller.SetCurrentProgress(-1);

        String OPTION_USE_STEAM_ARTWORK = this.app.settings.Get("OPTION_USE_STEAM_ARTWORK");
        if ("true".equals(OPTION_USE_STEAM_ARTWORK)) {
            String OPTION_ARTWORK = this.app.settings.Get("OPTION_TITLE_ARTWORK");
            HashMap<String, Integer> GameToID = new HashMap<String, Integer>();
            GameToID.put("heretic", 2390);
            GameToID.put("heretic.shadow", 2390);
            GameToID.put("hexen", 2360);
            GameToID.put("hexen.deathkings", 2370);
            GameToID.put("hexen2", 9060);

            // uses widescreen ids
            if (!GameToID.containsKey(OPTION_ARTWORK)) {
                String[] list = {
                        "heretic", "hexen",
                        "hexen.deathkings", "hexen2"
                };
                int rng = new Random().nextInt(list.length - 1);
                OPTION_ARTWORK = list[rng];
            }
            try {
                // Download once and cache
                String path = this.app.settings.GetPath("temp");
                String path_cache = this.app.settings.GetPath("cache");

                File titlePNG = new File(path + "/graphics/title.png");
                File heroJPG = new File(path_cache + "/steam_hero_artwork/_temp.jpg");
                File steamPNG = new File(path_cache + String.format("/steam_hero_artwork/%s.png", OPTION_ARTWORK));
                Util.CreateDirectory(heroJPG.getAbsoluteFile().getParent());


                if (!steamPNG.exists()) {
                    this.app.controller.SetCurrentLabel("Downloading");
                    int id = GameToID.get(OPTION_ARTWORK);

                    String uriHero = "https://cdn.cloudflare.steamstatic.com/steam/apps/%d/library_hero.jpg";
                    URL dl = new URI(String.format(uriHero, id)).toURL();
                    InputStream in = dl.openStream();
                    Files.copy(in, Path.of(heroJPG.getAbsolutePath()), StandardCopyOption.REPLACE_EXISTING);

                    BufferedImage bufferedImage = ImageIO.read(heroJPG);
                    ImageIO.write(bufferedImage, "png", steamPNG);
                    heroJPG.delete();
                    Files.copy(steamPNG.toPath(), titlePNG.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
                Files.copy(steamPNG.toPath(), titlePNG.toPath(), StandardCopyOption.REPLACE_EXISTING);
                hideAdvisory = true;
            } catch (URISyntaxException | IOException e) {
                throw new RuntimeException(e);
            }
        }
    }

    private void DownloadKoraxLocalization() {
        String OPTION_KORAX_LANGUAGE = this.app.settings.Get("OPTION_KORAX_LOCALE");
        if (OPTION_KORAX_LANGUAGE.equals("en")) {
            return;
        }

        HashMap<String, String> locale = new HashMap<String, String>();
        switch (OPTION_KORAX_LANGUAGE) {
            case "fr" -> {
                locale.put("GRTNGS1", "https://tcrf.net/images/c/cf/Hexen64_koraxvoicegreetings-French.ogg");
                locale.put("READY1", "https://tcrf.net/images/0/06/Hexen64_koraxvoiceready-French.ogg");
                locale.put("BLOOD1", "https://tcrf.net/images/a/a1/Hexen64_koraxvoiceblood-French.ogg");
                locale.put("GAME1", "https://tcrf.net/images/b/b6/Hexen64_koraxvoicegame-French.ogg");
                locale.put("BOARD1", "https://tcrf.net/images/8/87/Hexen64_koraxvoiceboard-French.ogg");
                locale.put("WRSHIP1", "https://tcrf.net/images/7/78/Hexen64_koraxvoiceworship-French.ogg");
                locale.put("MAYBE1", "https://tcrf.net/images/0/04/Hexen64_koraxvoicemaybe-French.ogg");
                locale.put("STRONG1", "https://tcrf.net/images/3/33/Hexen64_koraxvoicestrong-French.ogg");
                locale.put("FACE1", "https://tcrf.net/images/7/7a/Hexen64_koraxvoiceface-French.ogg");
            }
            case "de" -> {
                locale.put("GRTNGS1", "https://tcrf.net/images/9/96/Hexen64_koraxvoicegreetings-German.ogg");
                locale.put("READY1", "https://tcrf.net/images/5/5c/Hexen64_koraxvoiceready-German.ogg");
                locale.put("BLOOD1", "https://tcrf.net/images/5/5a/Hexen64_koraxvoiceblood-German.ogg");
                locale.put("GAME1", "https://tcrf.net/images/e/e7/Hexen64_koraxvoicegame-German.ogg");
                locale.put("BOARD1", "https://tcrf.net/images/c/ca/Hexen64_koraxvoiceboard-German.ogg");
                locale.put("WRSHIP1", "https://tcrf.net/images/a/a8/Hexen64_koraxvoiceworship-German.ogg");
                locale.put("MAYBE1", "https://tcrf.net/images/3/36/Hexen64_koraxvoicemaybe-German.ogg");
                locale.put("STRONG1", "https://tcrf.net/images/6/6c/Hexen64_koraxvoicestrong-German.ogg");
                locale.put("FACE1", "https://tcrf.net/images/0/0d/Hexen64_koraxvoiceface-German.ogg");
            }
            case "jp" -> {
                locale.put("GRTNGS1", "https://tcrf.net/images/8/8e/Hexen64_koraxvoicegreetings-Japanese.ogg");
                locale.put("READY1", "https://tcrf.net/images/6/6a/Hexen64_koraxvoiceready-Japanese.ogg");
                locale.put("BLOOD1", "https://tcrf.net/images/1/13/Hexen64_koraxvoiceblood-Japanese.ogg");
                locale.put("GAME1", "https://tcrf.net/images/d/db/Hexen64_koraxvoicegame-Japanese.ogg");
                locale.put("BOARD1", "https://tcrf.net/images/c/c5/Hexen64_koraxvoiceboard-Japanese.ogg");
                locale.put("WRSHIP1", "https://tcrf.net/images/6/69/Hexen64_koraxvoiceworship-Japanese.ogg");
                locale.put("MAYBE1", "https://tcrf.net/images/f/f5/Hexen64_koraxvoicemaybe-Japanese.ogg");
                locale.put("STRONG1", "https://tcrf.net/images/0/08/Hexen64_koraxvoicestrong-Japanese.ogg");
                locale.put("FACE1", "https://tcrf.net/images/4/48/Hexen64_koraxvoiceface-Japanese.ogg");
            }
            default -> {
                return;
            }
        }

        // Download once and cache
        System.out.println("Korax Localization");
        this.app.controller.SetStageLabel(String.format("Korax Localization (%s)", OPTION_KORAX_LANGUAGE.toUpperCase()));
        this.app.controller.SetCurrentProgress(0);
        AtomicInteger count = new AtomicInteger();
        locale.forEach((fn,uri) -> {
            this.app.controller.SetCurrentLabel(String.format("%s : %s", fn, new File(uri).getName()));
            String path = this.app.settings.GetPath("temp");
            String path_cache = this.app.settings.GetPath("cache");

            File soundOGG = new File(path + String.format("/sounds/%s.ogg", fn));
            File soundLMP = new File(path + String.format("/sounds/%s.lmp", fn));

            File audio = new File(path_cache + String.format("/tcrf/%s/%s.ogg", OPTION_KORAX_LANGUAGE, fn));

            Util.CreateDirectory(audio.getAbsoluteFile().getParent());

            try {
                if (!audio.exists()) {
                    URL dl = new URI(uri).toURL();
                    InputStream in = dl.openStream();
                    Files.copy(in, Path.of(audio.getAbsolutePath()), StandardCopyOption.REPLACE_EXISTING);
                }
                Files.copy(audio.toPath(), soundOGG.toPath(), StandardCopyOption.REPLACE_EXISTING);
                soundLMP.delete();
                this.app.controller.SetCurrentProgress((float)count.incrementAndGet() / locale.size());
            } catch (URISyntaxException | IOException e) {
                throw new RuntimeException(e);
            }
        });
    }

    private void ApplyUserOptions() {
        String path = this.app.settings.GetPath("temp");

        try {
            File fileInfo = new File(path + "/mapinfo.gameinfo");
            String info = new String(Files.readAllBytes(fileInfo.toPath()));

            // Title Artwork
            String OPTION_TITLE_MUSIC = this.app.settings.Get("OPTION_TITLE_MUSIC");
            HashMap<String, String> TitleMusic = new HashMap<String, String>();
            //TitleMusic.put("heretic", "MUS_TITL");
            TitleMusic.put("hexen", "HEXEN");
            TitleMusic.put("hexen2", "casa1");
            if (TitleMusic.containsKey(OPTION_TITLE_MUSIC)) {
                info = info.replace("titlemusic = \"MUS_TITL\"", String.format("titlemusic = \"%s\"", TitleMusic.get(OPTION_TITLE_MUSIC)));
            }
            if (hideAdvisory) {
                info = info.replace("advisorytime = 6", "advisorytime = 0");
            }

            PrintWriter pw = new PrintWriter(fileInfo.getPath());
            pw.print(info);
            pw.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private void WriteHexen2InstallCVAR(String value) {
        try {
            FileWriter fw = new FileWriter(this.app.settings.GetPath("temp") + "/cvarinfo.hx2");
            PrintWriter out = new PrintWriter(fw);
            out.println(String.format("server noarchive string hxdd_installed_hexen2 = \"%s\";", value));
            out.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private void ExportHXDDFiles() {
        System.out.println("Adding HXDD assets");
        String path = this.app.settings.GetPath("temp");

        this.app.controller.SetStageLabel("Adding HXDD Assets");
        this.app.controller.SetCurrentLabel("");
        this.app.controller.SetCurrentProgress(0);
        try {
            ResourceWalker rwAssets = new ResourceWalker("assets");

            int idx = 0;
            for (Pair<String, File> p : rwAssets.files) {
                File source = p.getValue();
                File target = new File(path + "/" + p.getKey());
                if (source.isDirectory()) {
                    this.app.controller.SetCurrentLabel(String.format("Creating folder %s", p.getKey()));
                    target.mkdirs();
                } else {
                    this.app.controller.SetCurrentLabel(String.format("Copying %s", p.getKey()));
                    Files.copy(source.toPath(), target.toPath(), REPLACE_EXISTING);
                }
                this.app.controller.SetCurrentProgress((double) ++idx / rwAssets.files.size());
            }
        } catch (IOException | URISyntaxException e) {
            e.printStackTrace();
        }
    }

    private boolean HasPAKFiles(String[] paths) {
        PAKTest pak = new PAKTest();
        for (String path : paths) {
            File filePAK = new File(path);
            if (filePAK.exists() && filePAK.isFile()) {
                boolean result = pak.Test(filePAK.getAbsolutePath());
                if (!result) {
                    return false;
                }
            } else {
                return false;
            }
        }
        return true;
    }

    private void ExportHXDDFileByName(String source, String target) {
        String pathTemporary = this.app.settings.GetPath("temp");
        Path out = Paths.get(pathTemporary + "/" + target);
        try {
            URL urlPath = ResourceWalker.class.getResource(source);
            URI uri = urlPath.toURI();
            if (uri.getScheme().equals("jar")) {
                FileSystem fileSystem = FileSystems.newFileSystem(uri, Collections.<String, Object>emptyMap());
                Path fsPath = fileSystem.getPath(source);
                Files.copy(fsPath, out, REPLACE_EXISTING);
                fileSystem.close();
            } else {
                Files.copy(Paths.get(uri), out, REPLACE_EXISTING);
            }
        } catch (URISyntaxException e) {
            throw new RuntimeException(e);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    // Create Hexen focused palette PK3 for wads using palette textures
    private void CreateHexenPalettePK3() {
        this.app.controller.SetCurrentLabel("Creating Hexen Palette PK3");
        this.app.controller.SetCurrentProgress(-1);
        try {
            WadFile wadFile = new WadFile(this.app.settings.Get("PATH_HEXEN"));
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

    private void Bundle() {
        this.app.controller.SetStageLabel("Packaging HXDD");
        this.app.controller.SetCurrentLabel("");
        this.app.controller.SetCurrentProgress(-1);

        System.out.println("Packaging HXDD.ipk3");
        String Settings_TempPath = this.app.settings.GetPath("temp");
        File fileTemporary = new File(Settings_TempPath);
        File fileIpk3 = new File("./HXDD.ipk3");
        ZipUtil.pack(fileTemporary, fileIpk3, new NameMapper() {
            public String map(String name) {
                return name;
            }
        });
        ZipUtil.iterate(fileIpk3, new ZipEntryCallback() {
            public void process(InputStream in, ZipEntry zipEntry) throws IOException {
                if (!zipEntry.isDirectory() && zipEntry.getName().startsWith("iwadinfo.hxdd")) {
                    String owner = System.getProperty("user.name");
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm a");
                    LocalDateTime now = LocalDateTime.now();
                    String creation_date = now.format(formatter);
                    zipEntry.setComment(String.format("Creator: %s Creation Time: %s", owner, creation_date));
                }
            }
        });
        this.app.controller.SetCurrentLabel("Cleaning folder");
        this.app.controller.SetCurrentProgress(-1);
        System.out.println("Cleaning up temporary data");
        CleanFolder(this.app.settings.GetPath("temp"));
        CleanFolder(this.app.settings.GetPath("hexen2"));
        System.out.println("\nComplete! Copy HXDD.ipk3 to your GZDOOM wad folder and select it from the start menu!");
        // show complete screen
        this.app.controller.SetCurrentLabel("");
        this.app.controller.SetCurrentProgress(100);
        this.app.controller.SetStageLabel("COMPLETE!");

        this.app.controller.ShowComplete();
    }

    public void WriteInstallLanguageLookup() {
        try {
            Properties p_gitversion = GITVersion.getInstance().GetProperties();
            String version = p_gitversion.getProperty("git.closest.tag.name");
            if (version != null && version.equals("")) {
                version = p_gitversion.getProperty("git.build.version");
            }

            String SettingPathTemp = this.app.settings.GetPath("temp");
            FileWriter fw = new FileWriter(SettingPathTemp + "/language.build", false);
            PrintWriter out = new PrintWriter(fw);
            out.println("[en default]");
            out.println(String.format("HXDD_BUILD_BRANCH = \"%s\";", p_gitversion.getProperty("git.branch")));
            out.println(String.format("HXDD_BUILD_VERSION = \"%s\";", version));
            out.println(String.format("HXDD_BUILD_TAG_DISTANCE = \"%s\";", p_gitversion.getProperty("git.closest.tag.commit.count")));
            out.println(String.format("HXDD_BUILD_TIME = \"%s\";", p_gitversion.getProperty("git.build.time")));
            out.println(String.format("HXDD_BUILD_COMMIT_ID = \"%s\";", p_gitversion.getProperty("git.commit.id.abbrev")));
            out.println(String.format("HXDD_BUILD_COMMIT_ID_FULL = \"%s\";", p_gitversion.getProperty("git.commit.id.full")));
            out.println(String.format("HXDD_BUILD_COMMIT_TIME = \"%s\";", p_gitversion.getProperty("git.commit.time")));
            out.println(String.format("HXDD_BUILD_VERSION_ID = \"%s %s\";", version, p_gitversion.getProperty("git.commit.id.abbrev")));
            out.println(String.format("HXDD_BUILD_VERSION_ID_DATE_OPT = \"Build: %s %s %s\";", version, p_gitversion.getProperty("git.commit.id.abbrev"), p_gitversion.getProperty("git.commit.time")));
            out.close();

            fw = new FileWriter(SettingPathTemp + "/language.owner", false);
            out = new PrintWriter(fw);
            out.println("[en default]");
            out.println(String.format("HXDD_INSTALL_USER = \"%s\";", System.getProperty("user.name")));
            out.println(String.format("HXDD_INSTALL_OS = \"%s\";", System.getProperty("os.name")));
            out.println(String.format("HXDD_INSTALL_OS_ARCH = \"%s\";", System.getProperty("os.arch")));
            out.println(String.format("HXDD_INSTALL_OS_VERSION = \"%s\";", System.getProperty("os.version")));
            out.println(String.format("HXDD_INSTALL_TIME = \"%s\";", LocalDateTime.now()));
            out.println(String.format("HXDD_CREATION_FOLDER = \"%s\";", System.getProperty("user.dir")));
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void CleanFolder(String path) {
        try {
            File folder = new File(path);
            if (folder.exists()) {
                FileUtils.cleanDirectory(folder);
                folder.delete();
            }
        } catch (IOException e) {
            //e.printStackTrace();
        }
    }

    private void PostProcessImageData(String path, Color from, Color to) {
        // fixes transparency
        try {
            File fileTarget = new File(path);
            BufferedImage source = ImageIO.read(fileTarget);

            Image image = colorSwap(source, from, to);
            BufferedImage transparent = imageToBufferedImage(image);

            ImageIO.write(transparent, "PNG", fileTarget);
        } catch (IOException e) {
            System.out.println(path);
            e.printStackTrace();
        }
    }

    public static Image colorSwap(BufferedImage im, final Color from, final Color to) {
        ImageFilter filter = new RGBImageFilter() {
            public final int filterRGB(int x, int y, int rgb) {
                if ((from.getRGB() | 0xFF000000) == (rgb | 0xFF000000)) {
                    return to.getRGB();
                }
                return rgb;
            }
        };

        ImageProducer ip = new FilteredImageSource(im.getSource(), filter);
        return Toolkit.getDefaultToolkit().createImage(ip);
    }

    private static BufferedImage imageToBufferedImage(Image image) {
        BufferedImage bufferedImage = new BufferedImage(image.getWidth(null), image.getHeight(null), BufferedImage.TYPE_INT_ARGB);
        Graphics2D g2 = bufferedImage.createGraphics();
        g2.drawImage(image, 0, 0, null);
        g2.dispose();

        return bufferedImage;
    }
}
