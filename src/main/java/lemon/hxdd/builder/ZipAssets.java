package lemon.hxdd.builder;

import lemon.hxdd.Application;
import net.mtrop.doom.Wad;
import net.mtrop.doom.WadFile;
import net.mtrop.doom.graphics.Flat;
import net.mtrop.doom.graphics.PNGPicture;
import net.mtrop.doom.graphics.Palette;
import net.mtrop.doom.graphics.Picture;
import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.util.GraphicUtils;
import org.zeroturnaround.zip.ZipEntryCallback;
import org.zeroturnaround.zip.ZipUtil;
import org.zeroturnaround.zip.commons.IOUtils;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.zip.ZipEntry;

// Much like WADAssets, this will extract assets from GZDoom's pk3 files.
// ref: https://github.com/zeroturnaround/zt-zip
public class ZipAssets {
    Application app;
    File zipFile;

    ZipAssets(Application parent) {
        this.app = parent;
    }

    void SetFile(File zf) {
        this.zipFile = zf;
    }

    // Dumps files into Temporary
    void ExtractSingleFile(String input, String output) {
        String path = this.app.settings.GetPath("temp");
        File fileOutputFolder = new File(path);
        if (!fileOutputFolder.exists()) {
            fileOutputFolder.mkdirs();
        }

        ZipUtil.unpackEntry(this.zipFile, input, new File(path + "/" + output));
    }

    byte[] ExtractFileAsData(String path) {
        return ZipUtil.unpackEntry(new File(path), path);
    }

    void ExtractFilesFromFolder(String input, String output) {
        String path = this.app.settings.GetPath("temp");
        File fileOutputFolder = new File(path + output);
        if (!fileOutputFolder.exists()) {
            fileOutputFolder.mkdirs();
        }

        //System.out.println("Opening PK3 " + wadPath + this.zipFile);
        ZipUtil.iterate(this.zipFile, new ZipEntryCallback() {
            public void process(InputStream in, ZipEntry zipEntry) throws IOException {
                if (!zipEntry.isDirectory() && zipEntry.getName().startsWith(input)) {
                    String fileName = zipEntry.getName();
                    String cleanedName = fileName.startsWith(input) ? fileName.substring(input.length()) : fileName;
                    File fileOutput = new File(path + output + "/" + cleanedName);
                    OutputStream outputStream = new FileOutputStream(fileOutput);
                    IOUtils.copy(in, outputStream);
                }
            }
        });
    }

    void ExtractFilesFromFolderAndConvert(String input, String output, String[] limitedFiles, int[] dims) {
        String path = this.app.settings.GetPath("temp");
        File fileOutputFolder = new File(path + "/" + output);
        if (!fileOutputFolder.exists()) {
            fileOutputFolder.mkdirs();
        }

        /*
        Palette pal = null;
        try {
            pal = wad.getDataAs("PLAYPAL", Palette.class);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        */
        Palette pal = GraphicUtils.DOOM;
        if (input.contains("heretic")) {
            pal  = GraphicUtils.HERETIC;
        } else if (input.contains("hexen")) {
            pal = GraphicUtils.HEXEN;
        }

        //System.out.println("Opening PK3 " + wadPath + this.zipFile);
        final Palette finalPal = pal;
        ZipUtil.iterate(this.zipFile, new ZipEntryCallback() {
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
                            String npath = path + "/" + output + "/" + cleanedName.replace("lmp", "png");
                            if (dims != null) {
                                ExportGraphic(npath, in, finalPal, dims);
                            } else {
                                Export(npath, in, finalPal, dims);
                            }
                        } else {
                            try {
                                File fileOutput = new File(path + "/" + output + "/" + cleanedName);
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

    private void Export(String path, InputStream in, Palette pal, int[] dimensions) {
        try {
            File fileOutput = new File(path);
            Picture p = new Picture();

            byte[] bytesGraphic = GetBytesFromInputStream(in);
            p.fromBytes(bytesGraphic);
            if (dimensions != null) {
                p.setDimensions(dimensions[0], dimensions[1]);
            }

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

    private void ExportGraphic(String path, InputStream in, Palette pal, int[] dimensions) {
        try {
            File target = new File(path);

            BufferedImage image = null;

            boolean AsFlat = false;
            if (AsFlat) {
                // Results in corrupted data: https://github.com/MTrop/DoomStruct/issues/17#issuecomment-1603050005
                Flat f = Flat.read(dimensions[0], dimensions[1], in);
                image = GraphicUtils.createImage(f, pal);
            } else {
                Picture p = new Picture();
                p.setDimensions(dimensions[0], dimensions[1]);
                p.readBytes(in);
                image = GraphicUtils.createImage(p, pal);
            }
            ImageIO.write(image, "PNG", target);
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
