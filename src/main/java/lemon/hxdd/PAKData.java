package lemon.hxdd;

// Uses Noesis for PAK extraction and file type conversion

import net.mtrop.doom.graphics.Flat;
import net.mtrop.doom.graphics.PNGPicture;
import net.mtrop.doom.graphics.Palette;
import net.mtrop.doom.util.GraphicUtils;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.*;
import java.io.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class PAKData {
    static String[] PAKFiles = {"pak0", "pak1", "pak3"};

    static public ArrayList<String> Extract() {
        String pathWADs = (String) Settings.getInstance().Get("PathSourceWads");
        String pathOutput = (String) Settings.getInstance().Get("PathHexen2") + "/data1/";
        File dirFile = new File(pathOutput);
        if (!dirFile.exists()) {
            dirFile.mkdirs();
        }

        ArrayList<String> extractedPaks = new ArrayList<String>();
        ProgressBar p = new ProgressBar("PAK extration");
        float count = 0;
        for (String file : PAKFiles) {
            File pakFile = new File(pathWADs + "/" + file + ".pak");
            if (pakFile.exists()) {
                Noesis.ExtractPak(file + ".pak", pathOutput);
                extractedPaks.add(file);
            }
            p.SetPercent(++count / (float)PAKFiles.length);
        }
        return extractedPaks;
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

        Boolean Settings_UseMultiPass = (Boolean) Settings.getInstance().Get("Hexen2_UseMultiPass");
        ProgressBar p = new ProgressBar("Asset Export & Conversion");
        float count = 0;
        for (File asset : assetListing) {
            String fileName = asset.getPath();
            String fileNameFix =  fileName.replace(".\\", "");
            if (fileName.endsWith(".mdl")) {
                String opt = "";
                if (fileName.contains("boss")) {
                    opt = "boss_";
                } else if (fileName.contains("puzzle")) {
                    opt = "puzzle_";
                }

                // Slow Path, export as lmp for manual processing
                if (Settings_UseMultiPass) {
                    final String[] options = {
                            "-imgoutidx 70",
                            "-nofmtexopt",
                            "-vorder",
                            "-smoothnorm \"180\"",
                            "-texpre \"" + opt + "%s\""
                    };
                    Noesis.ExportAsset(fileNameFix, "models/" + opt, options);
                } else {
                    final String[] options = {
                            "-vorder",
                            "-smoothnorm \"180\"",
                            "-texpre \"" + opt + "%s\""
                    };
                    Noesis.ExportAsset(fileNameFix, "models/" + opt, options);
                }
            } else if (fileName.endsWith(".spr")) {
                final String[] options = {"-texnorepfn", "-forcetc", "-logfile coords.txt"};
                Noesis.ExportAsset(fileNameFix, "sprites/", options);
                AddImageCoords();
            } else if (fileName.endsWith(".lmp")) {
                final String[] options = {"-forcetc"};
                Noesis.ExportAsset(fileNameFix, "graphics/", options);
                //FixImageCoords();
            }
            p.SetPercent(++count / (float)assetListing.size());
        }



        try {
            File logCoords = new File("./coords.txt");
            Files.deleteIfExists(logCoords.toPath());
        } catch (IOException e) {
            //e.printStackTrace();
        }

        // Converts Hexen II LMPs to PNGs (with Transparency Pass) and Brightmap PNGs.
        if (Settings_UseMultiPass) {
            LMPExport();
        }
    }

    static private void LMPExport() {
        String Settings_PathTemp = (String) Settings.getInstance().Get("PathTemporary");
        String PathTempModels = Settings_PathTemp + "models/";
        String PathTempBrightmaps = Settings_PathTemp + "brightmaps/";
        File dirFile = new File(PathTempBrightmaps);
        if (!dirFile.exists()) {
            dirFile.mkdirs();
        }

        // Load pal data
        Palette h2pal = Shared.GetHexen2Palette();
        Palette h2paltransparency = Shared.GetHexen2TransparencyPalette();
        Palette h2brightmap = Shared.GetHexen2BrightmapPalette();

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

        ProgressBar p = new ProgressBar("Creating Model Textures & Brightmaps");
        float count = 0;
        for (File assetFile : assetListing) {
            // Quake Texture LMPs are very close to DOOM Flat/Screen LMPs
            byte[] fData = null;
            int width = 0;
            int height = 0;
            byte[] data = null;
            try {
                fData = Files.readAllBytes(assetFile.toPath());

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
                CreateModelTexture(assetFile, data, width, height, h2paltransparency, h2brightmap);
            }

            p.SetPercent(++count / (float)assetListing.size());
        }
    }

    static private void CreateModelTexture(File assetFile, byte[] data, int width, int height, Palette pal, Palette palBrightmap) {
        String Settings_PathTemp = (String) Settings.getInstance().Get("PathTemporary");
        String PathTempModels = Settings_PathTemp + "models/";
        String PathTempBrightmaps = Settings_PathTemp + "brightmaps/";

        try {
            // load lmp as binary with 0 offset pal
            Flat f = Flat.create(width, height, data);
            BufferedImage image = GraphicUtils.createImage(f, pal);

            // Use an altered Palette for transparency processing
            // Makes it easier to use Java's image libraries to convert 100,100,100 to a transparent region.
            Color colorTarget = new Color(100,100,100);
            Image result = makeColorTransparent(image, colorTarget);
            BufferedImage bufferedResult = imageToBufferedImage(result);

            File out = new File(PathTempModels + assetFile.getName().replace(".lmp", ".png"));
            ImageIO.write(bufferedResult, "PNG", out);

            f = Flat.create(width, height, data);
            image = GraphicUtils.createImage(f, palBrightmap);

            DataBuffer idb = image.getData().getDataBuffer();
            for (int i = 0; i < idb.getSize(); i++) {
                if (idb.getElem(i) == -1) {
                    out = new File(PathTempBrightmaps + assetFile.getName().replace(".lmp", ".png"));
                    ImageIO.write(image, "PNG", out);
                    break;
                }
            }


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

    public static Image makeColorTransparent(BufferedImage im, final Color color) {
        ImageFilter filter = new RGBImageFilter() {

            // the color we are looking for... Alpha bits are set to opaque
            public int markerRGB = color.getRGB() | 0xFF000000;

            public final int filterRGB(int x, int y, int rgb) {
                if ((rgb | 0xFF000000) == markerRGB) {
                    // Mark the alpha bits as zero - transparent
                    return 0x00FFFFFF & rgb;
                } else {
                    // nothing to do
                    return rgb;
                }
            }
        };

        ImageProducer ip = new FilteredImageSource(im.getSource(), filter);
        return Toolkit.getDefaultToolkit().createImage(ip);
    }

    static private void AddImageCoords() {
        Pattern patternCoords = Pattern.compile("\\-*\\d+");
        Pattern patternFileName = Pattern.compile("([^\\s]+)");

        File logCoords = new File("./coords.txt");
        List<String> content = null;
        try {
            content = Files.readAllLines(logCoords.toPath());

            List<String> frames = new ArrayList<String>();
            for (String line : content) {
                if (line.startsWith("Writing") || line.equals("Detected file type: Unknown")) {
                    break;
                } else if (!line.startsWith("Detected")) {
                    frames.add(line);
                }
            }

            int index = 0;
            String first4thChar = "";
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
                pngImg.setOffsetX(x);
                pngImg.setOffsetY(y);

                // Generate a doom engine friendly name from file
                int wrapIndex = index % 26;
                String normalizedName = matchedFileName.toUpperCase().replace("_", "");
                String shortName = normalizedName.substring(0, 3);
                String shortName4th = normalizedName.substring(3, 4);
                String nameNumber = matched.size() == 7 ? matched.get(0) : "";
                String alphaIndex = frames.size() > 26 ? GetCharFromInt((int)Math.floor((double)index / 26)) : "";
                String alphaFrame = GetCharFromInt(wrapIndex);

                if (matched.size() < 7) {
                    if (first4thChar.equals("")) {
                        first4thChar = shortName4th;
                    } else {
                        shortName4th = first4thChar;
                    }

                    shortName = shortName + shortName4th;
                }

                // Prevents name conflict with Hexen XPL1 sprite.
                if (shortName.equals("XPL")) {
                    nameNumber = String.format("%d", Integer.parseInt(nameNumber) + 1);
                }
                if (nameNumber.length() > 1) {
                    nameNumber = nameNumber.substring(0,1);
                }

                String outName = shortName + nameNumber + alphaIndex + alphaFrame + "0";

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
