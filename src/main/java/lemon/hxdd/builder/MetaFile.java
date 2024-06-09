package lemon.hxdd.builder;

import net.mtrop.doom.Wad;
import net.mtrop.doom.WadFile;
import net.mtrop.doom.graphics.Flat;
import net.mtrop.doom.graphics.PNGPicture;
import net.mtrop.doom.graphics.Palette;
import net.mtrop.doom.graphics.Picture;
import net.mtrop.doom.sound.DMXSound;
import net.mtrop.doom.sound.MUS;
import net.mtrop.doom.util.GraphicUtils;
import net.mtrop.doom.util.SoundUtils;

import javax.imageio.ImageIO;
import javax.sound.sampled.AudioFileFormat;
import javax.sound.sampled.UnsupportedAudioFileException;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.Charset;
import java.util.Objects;

public class MetaFile {
    String source;
    String sourcePK3;
    String inputName;
    String outputName;
    String type;
    String folder;
    String decodeType;
    int[] dimensions;

    Wad wad;

    ZipAssets za;

    String pathTemp;

    MetaFile() {
    }

    public void Define(String name, String folder, String sourceName) {
        this.source = sourceName;   // check if pk3 from filename
        this.sourcePK3 = null;      // PK3 file, overrides wad extract
        this.inputName = name;      // input filename
        this.outputName = name;     // output filename
        this.folder = folder;       // export folder
        this.decodeType = folder;   // decode method
        this.dimensions = null;     // used by fullscreen images
    }

    public void ExtractFile(String path) {
        this.pathTemp = path;
        // Get data from WAD or PK3 ZIP.
        try {
            if (this.sourcePK3 != null) {
                this.ExtractFromPK3();
            } else {
                this.ExtractFromWad();
            }
        } catch (IOException e) {
            // log error
        }
    }

    public void ExtractFromWad() throws IOException {
        this.wad = new WadFile(this.source);
        byte[] data = this.wad.getData(this.inputName);

        Palette pal = GetPlaypal();
        ExportData(data, pal);

        this.wad.close();
    }

    public void ExtractFromPK3() {
        // Extract from ZIP
        //ZipAssets pk3 = new ZipAssets(this.mf.sourcePK3 + ".pk3");
        this.za.SetFile(new File(this.sourcePK3));
        byte[] data = this.za.ExtractFileAsData(this.inputName);
        Palette pal = GetPlaypal();
        ExportData(data, pal);
    }

    public void SetWad(Wad wf) {
        this.wad = wf;
    }

    private void ExportData(byte[] data, Palette pal) {
        if (this.decodeType.equals("lumps")) {
            LumpExport(data);
        } else if (Objects.equals(this.decodeType, "textlumps")) {
            TextLumpExport(data);
        } else if (Objects.equals(this.decodeType, "graphics") || Objects.equals(this.decodeType, "patches") || Objects.equals(this.decodeType, "sprites")) {
            GraphicsExport(data, pal);
        } else if (Objects.equals(this.decodeType, "flats")) {
            FlatExport(data, pal);
        } else if (Objects.equals(this.decodeType, "sounds")) {
            SoundExport();
        } else if (Objects.equals(this.decodeType, "music")) {
            boolean lowerVolume = this.source.contains("heretic");
            MusicExport(lowerVolume);
        } else {
            // lump
            LumpExport(data);
        }
    }

    private void CreateFolder(String path) {
        File dirFile = new File(path);
        if (!dirFile.exists()) {
            dirFile.mkdirs();
        }
    }

    private Palette GetPlaypal() {
        Palette pal = null;
        try {
            pal = this.wad.getDataAs("playpal", Palette.class);
        } catch (IOException e) {
            // Failed to open wad
            e.printStackTrace();
        }

        return pal;
    }

    // Decode Type handler
    private void LumpExport(byte[] data) {
        String path = this.pathTemp;
        this.CreateFolder(path);

        try {
            FileOutputStream fos = new FileOutputStream(path + "/" + this.outputName.toLowerCase() + ".lmp", false);
            fos.write(data);
            fos.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void TextLumpExport(byte[] data) {
        String path = this.pathTemp;
        //String path = (String) Settings.getInstance().Get("PathTemporary");
        this.CreateFolder(path);

        path = path + "/" + this.outputName;
        try {
            String lumpString = new String(data, Charset.defaultCharset());
            PrintWriter out = new PrintWriter(path);
            out.println(lumpString);
            out.close();

            //System.out.println("Exported " + path);
        } catch (IOException e) {
            System.out.println("Failed to export lump " + path + " from " + this.source);
        }
    }

    // Sprites, Patches, and UI Graphics
    private void GraphicsExport(byte[] data, Palette pal) {
        String path = this.pathTemp + "/" + this.folder + "/";
        //String path = Settings.getInstance().Get("PathTemporary") + "/" + this.mf.folder + "/";
        String imagePath = path + this.outputName + ".png";
        this.CreateFolder(path);

        try {
            Picture p = new Picture();
            p.fromBytes(data);

            PNGPicture pngImg = GraphicUtils.createPNGImage(p, pal);

            // Get grAB offsets from DOOM Format and add to PNG output
            int offsetX = p.getOffsetX();
            int offsetY = p.getOffsetY();
            pngImg.setOffsetX(offsetX);
            pngImg.setOffsetY(offsetY);

            File newFile = new File(imagePath);
            pngImg.writeBytes(new FileOutputStream(newFile, false));

            //System.out.println("Exported " + imagePath);
        } catch (IOException e) {
            System.out.println("Failed to export graphics " + imagePath + " from " + this.source);
            //e.printStackTrace();
        }
    }

    private void FlatExport(byte[] data, Palette pal) {
        String path = this.pathTemp + "/flats/";
        //String path = Settings.getInstance().Get("PathTemporary") + "/flats/";
        String imagePath = path + this.outputName + ".png";
        this.CreateFolder(path);

        try {
            int width = 64;
            int height = 64;
            if (this.dimensions != null) {
                width = this.dimensions[0];
                height = this.dimensions[1];
            }

            Flat f = Flat.create(width, height, data);    // always 64x64 in Doom/Heretic/Hexen iwads
            BufferedImage image = GraphicUtils.createImage(f, pal);

            File newFile = new File(imagePath);
            ImageIO.write(image, "PNG", newFile);
        } catch (IOException e) {
            System.out.println("Failed to export flat " + imagePath + " from " + this.source);
        }
    }

    private void SoundExport() {
        String path = this.pathTemp + "/sounds/";
        //String path = Settings.getInstance().Get("PathTemporary") + "/sounds/";
        this.CreateFolder(path);

        Boolean AudioResample = false; //(Boolean) Settings.getInstance().Get("AudioResample");
        String AudioResampleInterpolation = "linear"; //(String) Settings.getInstance().Get("AudioResampleInterpolation");
        String AudioResampleRate = "44khz"; //(String) Settings.getInstance().Get("AudioResampleRate");

        String filePath = path + this.outputName;
        try {
            DMXSound sfx = wad.getDataAs(this.inputName, DMXSound.class);
            if (AudioResample) {
                int SampleRate = DMXSound.SAMPLERATE_44KHZ;
                if (AudioResampleRate.equals("22khz")) {
                    SampleRate = DMXSound.SAMPLERATE_22KHZ;
                } else if (AudioResampleRate.equals("11khz")) {
                    SampleRate = DMXSound.SAMPLERATE_11KHZ;
                } else if (AudioResampleRate.equals("8khz")) {
                    SampleRate = DMXSound.SAMPLERATE_8KHZ;
                }
                DMXSound.InterpolationType interpolationType = DMXSound.InterpolationType.LINEAR;
                if (AudioResampleInterpolation.equals("cubic")) {
                    interpolationType = DMXSound.InterpolationType.CUBIC;
                } else if (AudioResampleInterpolation.equals("cosine")) {
                    interpolationType = DMXSound.InterpolationType.COSINE;
                } else if (AudioResampleInterpolation.equals("none")) {
                    interpolationType = DMXSound.InterpolationType.NONE;
                }

                sfx.resample(interpolationType, SampleRate);
                SoundUtils.writeSoundToFile(sfx, AudioFileFormat.Type.WAVE, new File(filePath + ".wav"));
                //System.out.println("Exported & Resampled " + filePath + ".wav");
            } else {
                sfx.writeBytes(new FileOutputStream(filePath + ".lmp", false));
                //SoundUtils.writeSoundToFile(sfx, AudioFileFormat.Type.SND, new File(filePath + ".snd"));
                //System.out.println("Exported " + filePath + ".lmp");
            }
        } catch (IOException | UnsupportedAudioFileException e) {
            System.out.println("Failed to export flat " + filePath + " from " + this.source);
            e.printStackTrace();
        }
    }

    private void MusicExport(boolean lowerVolume) {
        String path = this.pathTemp + "/music/";
        //String path = Settings.getInstance().Get("PathTemporary") + "/music/";
        String filePath = path + this.outputName;
        this.CreateFolder(path);
        try {
            String target = filePath + ".mus";
            // MUS is picky, so we're pulling from Wad.
            MUS music = wad.getDataAs(this.inputName, MUS.class);
            if (lowerVolume) {
                for (int i = 0; i < music.getEventCount(); i++) {
                    MUS.Event e = music.getEvent(i);
                    // note play type
                    if (e.getType() == 1) {
                        MUS.NotePlayEvent c = (MUS.NotePlayEvent)e;
                        int Volume = c.getVolume();
                        if (Volume != -1) {
                            int newVolume = (int)(Volume * 0.5);
                            c.setVolume(newVolume);
                        }
                    }
                }
            }
            music.writeBytes(new FileOutputStream(target, false));
            //System.out.println("Exported " + filePath + ".mus");
        } catch (IOException e) {
            System.out.println("Failed to export " + filePath + ".mus" + " from " + this.source);
            //e.printStackTrace();
        }
    }
}
