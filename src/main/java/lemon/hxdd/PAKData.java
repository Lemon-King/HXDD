package lemon.hxdd;

// Uses Noesis for PAK extraction and file type conversion

import net.mtrop.doom.graphics.Flat;
import net.mtrop.doom.graphics.PNGPicture;
import net.mtrop.doom.graphics.Palette;
import net.mtrop.doom.util.GraphicUtils;
import org.zeroturnaround.zip.commons.FileUtils;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.*;
import java.io.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.Files;
import java.util.*;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class PAKData {
    // Model Effects
    static int EF_TRANSPARENT   = 1 << 12;		// Transparent sprite
    static int EF_HOLEY		    = 1 << 14;		// Solid model with color 0
    static int EF_SPECIAL_TRANS = 1 << 15;		// Translucency through the particle table

    static int[] ColorIndex = {0, 31, 47, 63, 79, 95, 111, 127, 143, 159, 175, 191, 199, 207, 223, 231};
    static int[] ColorPercent = {25, 51, 76, 102, 114, 127, 140, 153, 165, 178, 191, 204, 216, 229, 237, 247};

    /*
     * REF: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2MP/code/gl_draw.c#L1402
     * https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/Client/gl_model.c#L1523
     *
	 * if( mdl_flags & EF_HOLEY )
	 * 	texture_mode = 2;
	 * else if( mdl_flags & EF_TRANSPARENT )
	 * 	texture_mode = 1;
	 * else if( mdl_flags & EF_SPECIAL_TRANS )
	 * 	texture_mode = 3;
	 * else
     * 	texture_mode = 0;
     * mode:
     * 0 - standard
     * 1 - color 0 transparent, odd - translucent, even - full value
     * 2 - color 0 transparent
     * 3 - special (particle translucency table)
     */

    static int[] SparkOffsets = {41, 25};       // Sparks do not align correctly

    static String[] PAKFiles = {
            "pak0",     // Base Game Files (Demo)
            "pak1",     // Base Game Files (Registered)
            //"Pak2",   // Unknown
            "pak3",     // Expansion Files
            "pak4"      // Hexen World Files
    };

    static public ArrayList<String> Extract() {
        String pathWADs = (String) Settings.getInstance().Get("PathSourceWads");
        String pathHexen2 = Settings.getInstance().Get("PathHexen2") + "/data1/";
        Shared.CreateDirectory(pathHexen2);

        ArrayList<String> extractedPaks = new ArrayList<String>();
        ProgressBar p = new ProgressBar("PAK extraction");
        float count = 0;
        for (String file : PAKFiles) {
            File pakFile = new File(pathWADs + "/" + file + ".pak");
            if (pakFile.exists()) {
                Noesis.ExtractPak(file + ".pak", pathHexen2);
                extractedPaks.add(file);
            }
            p.SetPercent(++count / (float)PAKFiles.length);
        }

        ExportSounds();

        return extractedPaks;
    }

    static public void ExportSounds() {
        String pathSource = Settings.getInstance().Get("PathHexen2") + "/data1/sound";
        String pathTarget = Settings.getInstance().Get("PathTemporary") + "/sounds/hexen2";
        Shared.CreateDirectory(pathTarget);
        try {
            FileUtils.copyDirectory(new File(pathSource), new File(pathTarget));
            System.out.printf("Exported Hexen II sound data\n");
        } catch (IOException e) {
            System.out.printf("Failed to Export Hexen II sound data! ( %s )\n", e.getMessage());
        }
    }

    static public void ExportAssets() {
        String Settings_PathHexen2 = (String) Settings.getInstance().Get("PathHexen2");
        String[] folderPaths = {
            Settings_PathHexen2 + "data1/gfx/",
            Settings_PathHexen2 + "data1/gfx/menu/",
            Settings_PathHexen2 + "data1/gfx/puzzle/",
            Settings_PathHexen2 + "data1/models/",
            Settings_PathHexen2 + "data1/models/boss/",
            Settings_PathHexen2 + "data1/models/puzzle/",
            Settings_PathHexen2 + "data1/models/sprites/",
        };
        ArrayList<File> assetListing = new ArrayList<File>();
        for (String path : folderPaths) {
            File folderPath = new File(path);
            File[] pathFile = folderPath.listFiles();
            assert pathFile != null;
            for (File asset : pathFile) {
                if (asset.isFile()) {
                    assetListing.add(asset);
                }
            }
        }

        Map<String, String> ModelEffect = new HashMap<String, String>();

        Boolean Settings_UseMultiPass = (Boolean) Settings.getInstance().Get("Hexen2_UseMultiPass");
        ProgressBar p = new ProgressBar("Asset Export & Conversion");
        float count = 0;
        for (File entry : assetListing) {
            if (entry.isDirectory()) {
                continue;
            }
            String name = entry.getName();
            String shortName = name.replace(".mdl", "");
            String fileName = entry.getPath();
            String fileName_Noesis =  fileName.replace(".\\", "");  // Noesis has a path bug in some versions
            ArrayList<String> options = new ArrayList<String>();
            if (fileName.endsWith(".mdl")) {
                String opt = "";
                if (fileName.contains("boss")) {
                    opt = "boss_";
                } else if (fileName.contains("puzzle")) {
                    opt = "puzzle_";
                }

                // Read model and determine how to process
                try {
                    InputStream in = new FileInputStream(fileName);
                    in.skip(75);

                    byte[] bytes = new byte[4];
                    int size = in.read(bytes, 0, 4);
                    if (size == 4) {
                        ByteBuffer buffer = ByteBuffer.wrap(bytes); // big-endian by default
                        int flag = buffer.getInt();
                        if ((flag & EF_TRANSPARENT) != 0) {
                            // special handling, using custom lookups
                            ModelEffect.put(shortName, "EF_TRANSPARENT");
                        } else if ((flag & EF_SPECIAL_TRANS) != 0) {
                            // special handling, using custom lookups
                            ModelEffect.put(shortName, "EF_SPECIAL_TRANS");
                        } else if ((flag & EF_HOLEY) != 0) {
                            // Treat black pal 0 as transparent
                            ModelEffect.put(shortName, "EF_HOLEY");
                        }
                    }
                    in.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                options.add("-nofmtexopt");
                options.add("-vorder");
                options.add("-smoothnorm \"180\"");
                options.add("-texpre " + opt + "\"%s\"");
                if (ModelEffect.get(shortName) != null) {
                    options.add("-imgoutidx 70");
                }
                Noesis.ExportAsset(fileName_Noesis, "models/" + opt, options);
            } else if (fileName.endsWith(".spr")) {
                options.add("-texnorepfn");
                options.add("-forcetc");
                options.add("-logfile sprite_log.txt");
                Noesis.ExportAsset(fileName_Noesis, "sprites/", options);
                AddImageCoords(fileName.replace(".spr", ""));
            } else if (fileName.endsWith(".lmp")) {
                options.add("-forcetc");
                Noesis.ExportAsset(fileName_Noesis, "graphics/", options);
                //FixImageCoords();
            }
            p.SetPercent(++count / (float)assetListing.size());
        }

        try {
            File logCoords = new File("./sprite_log.txt");
            Files.deleteIfExists(logCoords.toPath());
        } catch (IOException e) {
            //e.printStackTrace();
        }

        // Converts Hexen II LMPs to PNGs (with Transparency Pass) and Brightmap PNGs.
        if (Settings_UseMultiPass) {
            LMPExport(ModelEffect);
        }
    }

    static private void LMPExport(Map<String, String> ModelEffect) {
        String Settings_PathTemp = (String) Settings.getInstance().Get("PathTemporary");
        String PathTempModels = Settings_PathTemp + "models/";
        //String PathTempBrightmaps = Settings_PathTemp + "brightmaps/";
        //Shared.CreateDirectory(PathTempBrightmaps);

        // Load pal data
        Palette palHexen2 = Shared.GetHexen2Palette();
        Palette palTransparency = Shared.GetHexen2TransparencyPalette();
        //Palette palBrightmap = Shared.GetHexen2BrightmapPalette();

        ArrayList<File> assetListing = new ArrayList<File>();
        File folderPath = new File(PathTempModels);
        File[] pathFile = folderPath.listFiles();
        assert pathFile != null;
        for (File asset : pathFile) {
            if (asset.isFile()) {
                if (asset.getName().contains(".lmp")) {
                    assetListing.add(asset);
                }
            }
        }

        ProgressBar p = new ProgressBar("Creating Model Textures");
        float count = 0;
        for (File asset : assetListing) {
            // Treat as Flat LMPs
            byte[] fData = null;
            int width = 0;
            int height = 0;
            byte[] data = null;
            try {
                fData = Files.readAllBytes(asset.toPath());

                ByteBuffer header = ByteBuffer.wrap(fData, 0, 8);
                header.order(ByteOrder.LITTLE_ENDIAN);
                width = header.getShort(0);
                height = header.getShort(4);

                int headerLen = 8;
                ByteBuffer d = ByteBuffer.wrap(fData, headerLen, fData.length - headerLen);
                data = new byte[d.remaining()];
                d.get(data);
            } catch (IOException e) {
                e.printStackTrace();
            }

            if (data != null) {
                String shortName = asset.getName().split("_")[0];
                Palette pal = palHexen2;
                String effect = ModelEffect.get(shortName);
                if (Objects.equals(effect, "EF_TRANSPARENT")) {
                    pal = palTransparency;
                } else if (Objects.equals(effect, "EF_SPECIAL_TRANS")) {
                    pal = palTransparency;
                } else if (Objects.equals(effect, "EF_HOLEY")) {
                    pal = palTransparency;
                }
                //System.out.printf("%s %s\n", shortName, effect);
                CreateModelTexture(asset, data, width, height, effect, pal);
            }

            p.SetPercent(++count / (float)assetListing.size());
        }
    }

    static private void CreateModelTexture(File asset, byte[] data, int width, int height, String effect, Palette pal) {
        String Settings_PathTemp = (String) Settings.getInstance().Get("PathTemporary");
        String PathTempModels = Settings_PathTemp + "models/";
        //String PathTempBrightmaps = Settings_PathTemp + "brightmaps/";

        try {
            // load lmp as binary with 0 offset pal
            Flat f = Flat.create(width, height, data);
            Image texture = GraphicUtils.createImage(f, pal);

            if (Objects.equals(effect, "EF_HOLEY") || Objects.equals(effect, "EF_TRANSPARENT") || Objects.equals(effect, "EF_SPECIAL_TRANS")) {
                Color colorTarget = new Color(100,100,100);
                Color colorNew = new Color(0,0,0, 0);
                texture = replaceColor(texture, colorTarget, colorNew);
            }

            // Largely a hack for Meteor Staff
            if (Objects.equals(effect, "EF_TRANSPARENT") || Objects.equals(effect, "EF_SPECIAL_TRANS")) {
                for (int i = 2; i < 255; i++) {
                    int argb = pal.getColorARGB(i);
                    int idx = pal.getNearestColorIndex(argb);

                    int targetAlpha = 255;
                    for (int j = 1; j < ColorIndex.length; j++) {
                        int index = ColorIndex[j];
                        if (index == 31 || index == 47 || index == 159) {
                            if (idx <= index && index - 18 <= idx) {
                                targetAlpha = ColorPercent[j];
                                break;
                            }
                        }
                    }

                    int r = (0x00ff0000 & argb) >> 16;
                    int g = (0x0000ff00 & argb) >> 8;
                    int b = (0x000000ff & argb);
                    Color colorTarget = new Color(r, g, b, 255);
                    Color colorNew = new Color(r, g, b, targetAlpha); //ColorPercent[argb & 15]);   // Hexen II transparency packing
                    texture = replaceColor(texture, colorTarget, colorNew);
                }
            }
            BufferedImage result = imageToBufferedImage(texture);

            File out = new File(PathTempModels + asset.getName().replace(".lmp", ".png"));
            ImageIO.write(result, "PNG", out);

            /*
            f = Flat.create(width, height, data);
            result = GraphicUtils.createImage(f, palBrightmap);

            DataBuffer idb = result.getData().getDataBuffer();
            for (int i = 0; i < idb.getSize(); i++) {
                if (idb.getElem(i) != 0) {
                    out = new File(PathTempBrightmaps + asset.getName().replace(".lmp", ".png"));
                    ImageIO.write(result, "PNG", out);
                    break;
                }
            }
            */


            // write brightmap to Hexen II brightmap file
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static BufferedImage imageToBufferedImage(Image image) {
        BufferedImage bufferedImage = new BufferedImage(image.getWidth(null), image.getHeight(null), BufferedImage.TYPE_INT_ARGB);
        Graphics2D g2 = bufferedImage.createGraphics();
        g2.drawImage(image, 0, 0, null);
        g2.dispose();

        return bufferedImage;
    }

    public static Image replaceColor(Image im, Color color, Color next) {
        ImageFilter filter = new RGBImageFilter() {
            public final int filterRGB(int x, int y, int rgb) {
                int markerRGB = color.getRGB() | 0xFF000000;
                if ((rgb | 0xFF000000) == markerRGB) {
                    return next.getRGB() | (next.getAlpha() << 24) & 0xFF000000;
                } else {
                    return rgb;
                }
            }
        };

        ImageProducer ip = new FilteredImageSource(im.getSource(), filter);
        return Toolkit.getDefaultToolkit().createImage(ip);
    }

    static private void AddImageCoords(String fileName) {
        Pattern patternCoords = Pattern.compile("\\-*\\d+");
        Pattern patternFileName = Pattern.compile("([^\\s]+)");

        File sprite_log = new File("./sprite_log.txt");
        List<String> content = null;
        try {
            content = Files.readAllLines(sprite_log.toPath());

            List<String> frames = new ArrayList<String>();
            for (String line : content) {
                if (line.startsWith("Writing") || line.equals("Detected file type: Unknown")) {
                    break;
                } else if (!line.startsWith("Detected")) {
                    frames.add(line);
                }
            }

            int index = 0;
            String firstIndexChar = "";
            for (String frame : frames) {
                List<String> matched = new ArrayList<String>();
                Matcher matcher = patternCoords.matcher(frame);
                while (matcher.find()) {
                    matched.add(matcher.group());
                }
                int length = matched.size();

                Matcher matcherFileName = patternFileName.matcher(frame);
                String matchedFileName = "";
                if (matcherFileName.find()) {
                    matchedFileName = matcherFileName.group();
                } else {
                    break;
                }

                File fileImage = new File("./temp/sprites/" + matchedFileName + ".png");
                BufferedImage source = ImageIO.read(fileImage);

                PNGPicture pngImg = new PNGPicture();
                pngImg.setImage(source);

                // Set grAB offsets from Quake Format and add to PNG output
                int x = Math.abs(Integer.parseInt(matched.get(length - 4)));
                int y = Integer.parseInt(matched.get(length - 3));
                if (matchedFileName.startsWith("spark_") || matchedFileName.startsWith("spark0_") ||
                        matchedFileName.startsWith("gspark_") || matchedFileName.startsWith("rspark_")) {
                    x = SparkOffsets[0];
                    y = SparkOffsets[1];
                }
                pngImg.setOffsetX(x);
                pngImg.setOffsetY(y);

                // Generate a doom engine friendly name from file
                int wrapIndex = index % 26;
                String normalizedName = matchedFileName.toUpperCase().replace("_", "");
                String spriteName = normalizedName.substring(0, 3);
                String nameIndex = normalizedName.substring(3, 4);
                String nameNumber = matched.size() == 7 ? matched.get(0) : "";
                String alphaIndex = frames.size() > 26 ? GetCharFromInt((int)Math.floor((double)index / 26)) : "";
                String charFrame = GetCharFromInt(wrapIndex);

                if (frames.size() > 26) {
                    spriteName = spriteName.substring(0, 2);
                }

                if (matched.size() < 7) {
                    if (firstIndexChar.equals("")) {
                        firstIndexChar = nameIndex;
                    } else {
                        nameIndex = firstIndexChar;
                    }

                    spriteName = spriteName + nameIndex;
                }

                // Prevents name conflict with Hexen XPL1 sprite.
                if (spriteName.equals("XPL")) {
                    nameNumber = String.format("%d", Integer.parseInt(nameNumber) + 1);
                }
                if (nameNumber.length() > 1) {
                    nameNumber = nameNumber.substring(0,1);
                }

                String outName = spriteName + nameNumber + alphaIndex + charFrame + "0";

                File newFile = new File("./temp/sprites/" + outName + ".png");
                pngImg.writeBytes(new FileOutputStream(newFile, false));

                Files.deleteIfExists(fileImage.toPath());

                index++;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    static private String GetCharFromInt(int i) {
        return String.valueOf((char)(i + 65));
    }
}
