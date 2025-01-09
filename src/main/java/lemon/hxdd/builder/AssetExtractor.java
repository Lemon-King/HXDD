package lemon.hxdd.builder;

import lemon.hxdd.Application;
import net.mtrop.doom.Wad;
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
import java.io.*;
import java.nio.charset.Charset;
import java.util.Objects;

// DEPRECATED

public class AssetExtractor {
    Application app;
    MetaFile mf;
    Wad wad;

    ZipAssets za;

    //public AssetExtractor(MetaFile mf, Wad mfWad) {
    //    this.mf = mf;
    //    this.wad = mfWad;
    //}

    public AssetExtractor(Application parent) {
        this.app = parent;

        this.za = new ZipAssets(this.app);
    }

    public void SetFile(MetaFile mf, Wad mfWad) {
        this.mf = mf;
        this.wad = mfWad;
    }

    public void ExtractFromWad() {
        // Get data from WAD or PK3 ZIP.
        byte[] data = null;
        try {
            data = this.wad.getData(mf.inputName);
        } catch (IOException e) {
            e.printStackTrace();
        }
        Palette pal = GetPlaypal();
        ExportData(data, pal);
    }

    private void ExportData(byte[] data, Palette pal) {
        if (Objects.equals(mf.decodeType, "lumps")) {
            LumpExport(data);
        } else if (Objects.equals(mf.decodeType, "textlumps")) {
            TextLumpExport(data);
        } else if (Objects.equals(mf.decodeType, "graphics") || Objects.equals(mf.decodeType, "patches") || Objects.equals(mf.decodeType, "sprites")) {
            GraphicsExport(data, pal);
        } else if (Objects.equals(mf.decodeType, "flats")) {
            FlatExport(data, pal);
        } else if (Objects.equals(mf.decodeType, "sounds")) {
            SoundExport();
        } else if (Objects.equals(mf.decodeType, "music")) {
            boolean lowerVolume = ("heretic").equals(mf.gameid);
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
        String path = this.app.settings.GetPath("temp");
        this.CreateFolder(path);

        try {
            FileOutputStream fos = new FileOutputStream(path + "/" + this.mf.outputName.toLowerCase() + ".lmp", false);
            fos.write(data);
            fos.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void TextLumpExport(byte[] data) {
        String path = this.app.settings.GetPath("temp");
        //String path = (String) Settings.getInstance().Get("PathTemporary");
        this.CreateFolder(path);

        path = path + "/" + this.mf.outputName;
        try {
            String lumpString = new String(data, Charset.defaultCharset());
            PrintWriter out = new PrintWriter(path);
            out.println(lumpString);
            out.close();

            //System.out.println("Exported " + path);
        } catch (IOException e) {
            System.out.println("Failed to export lump " + path);
        }
    }

    // Sprites, Patches, and UI Graphics
    private void GraphicsExport(byte[] data, Palette pal) {
        String path = this.app.settings.GetPath("temp") + "/" + this.mf.folder + "/";
        //String path = Settings.getInstance().Get("PathTemporary") + "/" + this.mf.folder + "/";
        String imagePath = path + this.mf.outputName + ".png";
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
            System.out.println("Failed to export graphics " + imagePath);
            //e.printStackTrace();
        }
    }

    private void FlatExport(byte[] data, Palette pal) {
        String path = this.app.settings.GetPath("temp") + "/flats/";
        //String path = Settings.getInstance().Get("PathTemporary") + "/flats/";
        String imagePath = path + this.mf.outputName + ".png";
        this.CreateFolder(path);

        try {
            int width = 64;
            int height = 64;
            if (mf.dimensions != null) {
                width = mf.dimensions[0];
                height = mf.dimensions[1];
            }

            Flat f = Flat.create(width, height, data);    // always 64x64 in Doom/Heretic/Hexen iwads
            BufferedImage image = GraphicUtils.createImage(f, pal);

            File newFile = new File(imagePath);
            ImageIO.write(image, "PNG", newFile);
        } catch (IOException e) {
            System.out.println("Failed to export flat " + imagePath);
        }
    }

    private void SoundExport() {
        String path = this.app.settings.GetPath("temp") + "/sounds/";
        //String path = Settings.getInstance().Get("PathTemporary") + "/sounds/";
        this.CreateFolder(path);

        Boolean AudioResample = false; //(Boolean) Settings.getInstance().Get("AudioResample");
        String AudioResampleInterpolation = "linear"; //(String) Settings.getInstance().Get("AudioResampleInterpolation");
        String AudioResampleRate = "44khz"; //(String) Settings.getInstance().Get("AudioResampleRate");

        String filePath = path + mf.outputName;
        try {
            DMXSound sfx = wad.getDataAs(this.mf.inputName, DMXSound.class);
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
            System.out.println("Failed to export flat " + filePath);
            e.printStackTrace();
        }
    }

    private void MusicExport(boolean lowerVolume) {
        String path = this.app.settings.GetPath("temp") + "/music/";
        //String path = Settings.getInstance().Get("PathTemporary") + "/music/";
        String filePath = path + mf.outputName;
        this.CreateFolder(path);
        try {
            String target = filePath + ".mus";
            // MUS is picky, so we're pulling from Wad.
            MUS musSeq = wad.getDataAs(this.mf.inputName, MUS.class);
            if (lowerVolume) {
                for (int i = 0; i < musSeq.getEventCount(); i++) {
                    MUS.Event e = musSeq.getEvent(i);
                    // note play type
                    if (e.getType() == 1) {
                        MUS.NotePlayEvent c = (MUS.NotePlayEvent)e;
                        int Volume = c.getVolume();
                        if (Volume != -1) {
                            int newVolume = (int)(Volume * 0.7);
                            c.setVolume(newVolume);
                        }
                    }
                }
            }
            musSeq.writeBytes(new FileOutputStream(target, false));
            //System.out.println("Exported " + filePath + ".mus");
        } catch (IOException e) {
            System.out.println("Failed to export " + filePath + ".mus");
            //e.printStackTrace();
        }
    }
}
