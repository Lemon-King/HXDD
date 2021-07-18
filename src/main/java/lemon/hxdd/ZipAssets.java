package lemon.hxdd;

import net.mtrop.doom.Wad;
import net.mtrop.doom.WadFile;
import net.mtrop.doom.graphics.PNGPicture;
import net.mtrop.doom.graphics.Palette;
import net.mtrop.doom.graphics.Picture;
import net.mtrop.doom.util.GraphicUtils;
import org.zeroturnaround.zip.ZipEntryCallback;
import org.zeroturnaround.zip.ZipUtil;
import org.zeroturnaround.zip.commons.IOUtils;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.Arrays;
import java.util.zip.ZipEntry;

// Much like WADAssets, this grabs assets from GZDoom's folders.
// ref: https://github.com/zeroturnaround/zt-zip
public class ZipAssets {
    String zipFile;

    ZipAssets(String name) {
        this.zipFile = name;
    }

    // Dumps files into Temporary
    void ExtractSingleFile(String input, String output) {
        String wadPath = (String) Settings.getInstance().Get("PathSourceWads");
        String TemporaryPath = (String) Settings.getInstance().Get("PathTemporary");
        File fileOutputFolder = new File(TemporaryPath);
        if (!fileOutputFolder.exists()) {
            fileOutputFolder.mkdirs();
        }

        ZipUtil.unpackEntry(new File(wadPath + this.zipFile), input, new File(TemporaryPath + "/" + output));
    }

    byte[] ExtractFileAsData(String path) {
        return ZipUtil.unpackEntry(new File(path), path);
    }

    void ExtractFilesFromFolder(String input, String output) {

        String wadPath = (String) Settings.getInstance().Get("PathSourceWads");
        String TemporaryPath = (String) Settings.getInstance().Get("PathTemporary");
        File fileOutputFolder = new File(TemporaryPath + output);
        if (!fileOutputFolder.exists()) {
            fileOutputFolder.mkdirs();
        }

        //System.out.println("Opening PK3 " + wadPath + this.zipFile);
        ZipUtil.iterate(new File(wadPath + this.zipFile), new ZipEntryCallback() {
            public void process(InputStream in, ZipEntry zipEntry) throws IOException {
                if (!zipEntry.isDirectory() && zipEntry.getName().startsWith(input)) {
                    String fileName = zipEntry.getName();
                    String cleanedName = fileName.startsWith(input) ? fileName.substring(input.length()) : fileName;
                    File fileOutput = new File(TemporaryPath + output + "/" + cleanedName);
                    OutputStream outputStream = new FileOutputStream(fileOutput);
                    IOUtils.copy(in, outputStream);
                }
            }
        });
    }

    void ExtractFilesFromFolderAndConvert(String input, String output, String wadName, String[] limitedFiles, int[] graphicDimensions) {
        String wadPath = (String) Settings.getInstance().Get("PathSourceWads");
        String TemporaryPath = (String) Settings.getInstance().Get("PathTemporary");
        File fileOutputFolder = new File(TemporaryPath + output);
        if (!fileOutputFolder.exists()) {
            fileOutputFolder.mkdirs();
        }

        Wad wad = null;
        Palette pal = null;

        try {
            wad = new WadFile(wadPath + wadName + ".wad");
            pal = wad.getDataAs("playpal", Palette.class);
        } catch (IOException e) {
            e.printStackTrace();
        }

        //System.out.println("Opening PK3 " + wadPath + this.zipFile);
        final Palette finalPal = pal;
        ZipUtil.iterate(new File(wadPath + this.zipFile), new ZipEntryCallback() {
            public void process(InputStream in, ZipEntry zipEntry) {
                if (!zipEntry.isDirectory() && zipEntry.getName().startsWith(input)) {
                    String fileName = zipEntry.getName();
                    String cleanedName = fileName.startsWith(input) ? fileName.substring(input.length()) : fileName;

                    if (limitedFiles != null && limitedFiles.length > 0) {
                        if (!Arrays.asList(limitedFiles).contains(cleanedName)) {
                            //System.out.println("Skipped file " + cleanedName);
                            return;
                        }
                    }
                    try {
                        if (fileName.contains(".lmp")) {
                            String path = TemporaryPath + output + "/" + cleanedName.replace("lmp", "png");
                            if (graphicDimensions != null) {
                                ExtractAsFullscreen(path, in, finalPal, graphicDimensions);
                            } else {
                                ExtractAsSprite(path, in, finalPal);
                            }
                        } else {
                            try {
                                File fileOutput = new File(TemporaryPath + output + "/" + cleanedName);
                                OutputStream outputStream = new FileOutputStream(fileOutput);
                                IOUtils.copy(in, outputStream);
                            } catch (IOException fileNotFoundException) {
                                fileNotFoundException.printStackTrace();
                            }
                        }
                        in.close();
                    } catch (Exception e) {
                        //e.printStackTrace();
                    }
                }
            }
        });
    }

    private void ExtractAsSprite(String path, InputStream in, Palette pal) {
        try {
            File fileOutput = new File(path);
            Picture p = new Picture();

            byte[] bytesGraphic = GetBytesFromInputStream(in);
            p.fromBytes(bytesGraphic);

            PNGPicture pngImg = GraphicUtils.createPNGImage(p, pal);
            int offsetX = p.getOffsetX();
            int offsetY = p.getOffsetY();
            if (offsetX != 0 || offsetY != 0) {
                pngImg.setOffsetX(offsetX);
                pngImg.setOffsetY(offsetY);
            }
            pngImg.writeBytes(new FileOutputStream(fileOutput, false));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void ExtractAsFullscreen(String path, InputStream in, Palette pal, int[] dimensions) {
        try {
            File fileOutput = new File(path);

            byte[] bytesGraphic = GetBytesFromInputStream(in);

            Picture p = new Picture();
            p.setDimensions(dimensions[0], dimensions[1]);
            p.fromBytes(bytesGraphic);

            BufferedImage image = GraphicUtils.createImage(p, pal);
            ImageIO.write(image, "PNG", fileOutput);
            //System.out.println("Wrote " + path);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private byte[] GetBytesFromInputStream(InputStream in) {
        byte[] bytes = new byte[0];
        try {
            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            int nRead;
            byte[] data = new byte[4];
            while ((nRead = in.read(data, 0, data.length)) != -1) {
                buffer.write(data, 0, nRead);
            }
            buffer.flush();
            bytes = buffer.toByteArray();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return bytes;
    }
}
