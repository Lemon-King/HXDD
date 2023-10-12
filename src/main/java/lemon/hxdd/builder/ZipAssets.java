package lemon.hxdd.builder;

import lemon.hxdd.Application;
import net.mtrop.doom.graphics.Flat;
import net.mtrop.doom.graphics.PNGPicture;
import net.mtrop.doom.graphics.Palette;
import net.mtrop.doom.graphics.Picture;
import net.mtrop.doom.util.GraphicUtils;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

// Much like WADAssets, this will extract assets from GZDoom's pk3 files.
public class ZipAssets {
    Application app;
    File zipFile;

    FileInputStream fis;
    ZipInputStream zis;

    ZipAssets(Application parent) {
        this.app = parent;
    }

    void SetFile(File zf) {
        this.zipFile = zf;
    }

    private void Open() {
        try {
            this.fis = new FileInputStream(this.zipFile);
            this.zis = new ZipInputStream(fis);
        } catch (FileNotFoundException e) {
        }
    }

    private void Close() {
        try {
            this.zis.close();
            this.fis.close();
        } catch (IOException e) {
        }
    }

    public void readZipStream(InputStream in) throws IOException {
        ZipInputStream zipIn = new ZipInputStream(in);
        ZipEntry entry;
        while ((entry = zipIn.getNextEntry()) != null) {
            //readContents(zipIn);
            zipIn.closeEntry();
        }
    }

    private void readContents(InputStream contentsIn) throws IOException {
        byte[] contents = new byte[4096];
        int direct;
        while ((direct = contentsIn.read(contents, 0, contents.length)) >= 0) {
            System.out.println("Read " + direct + "bytes content.");
        }
    }

    ArrayList<String> GetFolderContents(String path) {
        ArrayList<String> list = new ArrayList<String>();
        try {
            this.Open();

            ZipEntry entry;
            while ((entry = this.zis.getNextEntry()) != null) {
                if (!entry.isDirectory() && entry.getName().startsWith(path)) {
                    list.add(entry.getName());
                    this.zis.closeEntry();
                }
            }
        } catch (IOException e) {
            System.out.println("Error: " + e);
        }
        this.Close();
        return list;
    }

    String ReadFileAsString(String target) {
        String path = this.app.settings.GetPath("temp");

        try {
            this.Open();
            ZipEntry entry;
            while ((entry = this.zis.getNextEntry()) != null) {
                if (target.equals(entry.getName())) {

                    String data = new String(this.zis.readAllBytes());
                    this.zis.closeEntry();
                    return data;
                }
                this.zis.closeEntry();
            }
        } catch (IOException e) {
            System.out.println("Error: " + e);
        }
        this.Close();
        return "";
    }

    // Dumps files into Temporary
    void ExtractSingleFile(String input, String output) {
        String path = this.app.settings.GetPath("temp");

        try {
            this.Open();
            ZipEntry entry;
            while ((entry = this.zis.getNextEntry()) != null) {
                if (input.equals(entry.getName())) {
                    OutputStream os = new FileOutputStream(path + "/" + output);
                    os.write(this.zis.readAllBytes());
                    os.close();

                    this.zis.closeEntry();
                    break;
                }
                zis.closeEntry();
            }
        } catch (IOException e) {
            System.out.println("Error: " + e);
        }
        this.Close();
    }

    byte[] ExtractFileAsData(String path) {
        byte[] data = new byte[0];
        try {
            this.Open();
            ZipEntry entry;
            while ((entry = this.zis.getNextEntry()) != null) {
                if (entry.getName().equals(path)) {
                    data = this.zis.readAllBytes();
                    this.zis.closeEntry();
                    break;
                }
                this.zis.closeEntry();
            }
        } catch (IOException e) {
            System.out.println("Error: " + e);
        }
        this.Close();
        return data;
    }

    // https://stackoverflow.com/a/57997601
    public void PackFolder(File source, File target) {
        try {
            ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(target));
            Files.walkFileTree(source.toPath(), new SimpleFileVisitor<Path>() {
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                    zos.putNextEntry(new ZipEntry(source.toPath().relativize(file).toString()));
                    Files.copy(file, zos);
                    zos.closeEntry();
                    return FileVisitResult.CONTINUE;
                }
            });
            zos.close();

        } catch (IOException e) {
            System.out.println("Error: " + e);
        }
    }

    void ExtractFilesToFolder(String input, String output) {
        String path = this.app.settings.GetPath("temp");
        File fileOutputFolder = new File(path + "/" + output);
        if (!fileOutputFolder.exists()) {
            fileOutputFolder.mkdirs();
        }

        try {
            this.Open();
            ZipEntry entry;
            while ((entry = this.zis.getNextEntry()) != null) {
                if (entry.getName().startsWith(input)) {
                    if (entry.isDirectory()) {
                        File folder = new File(path + "/" + entry.getName());
                        if (!folder.exists()) {
                            folder.mkdirs();
                        }
                    } else {
                        String fileName = entry.getName();
                        String cleanedName = fileName.startsWith(input) ? fileName.substring(input.length()) : fileName;

                        try {
                            File fileOutput = new File(output + "/" + cleanedName);
                            File filePath = new File(fileOutput.getParent());
                            if (!filePath.exists()) {
                                filePath.mkdirs();
                            };
                            OutputStream outputStream = new FileOutputStream(fileOutput);
                            this.zis.transferTo(outputStream);
                            //outputStream.write(this.zis.readAllBytes());
                            outputStream.close();
                        } catch (IOException fileNotFoundException) {
                            fileNotFoundException.printStackTrace();
                        }
                    }
                }
                this.zis.closeEntry();
            }
        } catch (IOException e) {
            System.out.println("Error: " + e);
        }
        this.Close();
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

        final Palette finalPal = pal;

        try {
            this.Open();
            ZipEntry entry;
            while ((entry = this.zis.getNextEntry()) != null) {
                if (!entry.isDirectory() && entry.getName().startsWith(input)) {
                    String fileName = entry.getName();
                    String cleanedName = fileName.startsWith(input) ? fileName.substring(input.length()) : fileName;

                    if (limitedFiles != null && limitedFiles.length > 0) {
                        if (!Arrays.asList(limitedFiles).contains(cleanedName)) {
                            return;
                        }
                    }
                    try {
                        if (fileName.contains(".lmp")) {
                            String npath = path + "/" + output + "/" + cleanedName.replace("lmp", "png");
                            if (dims != null) {
                                ExportGraphic(npath, this.zis, finalPal, dims);
                            } else {
                                Export(npath, this.zis, finalPal, dims);
                            }
                        } else {
                            try {
                                File fileOutput = new File(path + "/" + output + "/" + cleanedName);
                                OutputStream outputStream = new FileOutputStream(fileOutput);
                                outputStream.write(this.zis.readAllBytes());
                                outputStream.close();
                            } catch (IOException fileNotFoundException) {
                                fileNotFoundException.printStackTrace();
                            }
                        }
                    } catch (Exception e) {
                    }
                }
                this.zis.closeEntry();
            }
        } catch (IOException e) {
            System.out.println("Error: " + e);
        }
        this.Close();
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
