package lemon.hxdd;

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

public class AssetExtractor {
    MetaFile mf;
    Wad wad;
    public AssetExtractor(MetaFile mf, Wad mfWad) {
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

    public void ExtractFromPK3() {
        // Extract from ZIP
        String path = (String) Settings.getInstance().Get("PathSourceWads");
        ZipAssets pk3 = new ZipAssets(path + this.mf.sourcePK3 + ".pk3");
        byte[] data = pk3.ExtractFileAsData(this.mf.inputName);
        Palette pal = GetPlaypal();
        ExportData(data, pal);
    }

    private void ExportData(byte[] data, Palette pal) {
        if (mf.decodeType == "lumps") {
            LumpExport(data);
        } else if (mf.decodeType == "textlumps") {
            TextLumpExport(data);
        } else if (mf.decodeType == "graphics" || mf.decodeType == "patches" || mf.decodeType == "sprites") {
            GraphicsExport(data, pal);
        } else if (mf.decodeType == "flats") {
            FlatExport(data, pal);
        } else if (mf.decodeType == "sounds") {
            SoundExport();
        } else if (mf.decodeType == "music") {
            MusicExport();
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
        String path = (String) Settings.getInstance().Get("PathTemporary");
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
        String path = (String) Settings.getInstance().Get("PathTemporary");
        this.CreateFolder(path);

        path = path + "/" + this.mf.outputName;
        try {
            String lumpString = new String(data, Charset.defaultCharset());
            PrintWriter out = new PrintWriter(path);
            out.println(lumpString);
            out.close();

            //System.out.println("Exported " + path);
        } catch (IOException e) {
            System.out.println("Failed to export lump " + path + " from " + mf.source);
        }
    }

    // Sprites, Patches, and UI Graphics
    private void GraphicsExport(byte[] data, Palette pal) {
        String path = Settings.getInstance().Get("PathTemporary") + "/" + this.mf.folder + "/";
        String imagePath = path + this.mf.outputName + ".png";
        this.CreateFolder(path);

        try {
            Picture p = new Picture();
            p.fromBytes(data);

            PNGPicture pngImg = GraphicUtils.createPNGImage(p, pal);

            // Get grAB offsets from DOOM Format and add to PNG output
            int offsetX = p.getOffsetX();
            int offsetY = p.getOffsetY();
            if (offsetX != 0 || offsetY != 0) {
                pngImg.setOffsetX(offsetX);
                pngImg.setOffsetY(offsetY);
            }

            File newFile = new File(imagePath);
            pngImg.writeBytes(new FileOutputStream(newFile, false));

            //System.out.println("Exported " + imagePath);
        } catch (IOException e) {
            System.out.println("Failed to export graphics " + imagePath + " from " + mf.source);
            //e.printStackTrace();
        }
    }

    private void FlatExport(byte[] data, Palette pal) {
        String path = Settings.getInstance().Get("PathTemporary") + "/flats/";
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
            System.out.println("Failed to export flat " + imagePath + " from " + mf.source);
        }
    }

    private void SoundExport() {
        String path = Settings.getInstance().Get("PathTemporary") + "/sounds/";
        this.CreateFolder(path);

        Boolean AudioResample = (Boolean) Settings.getInstance().Get("AudioResample");
        String AudioResampleInterpolation = (String) Settings.getInstance().Get("AudioResampleInterpolation");
        String AudioResampleRate = (String) Settings.getInstance().Get("AudioResampleRate");

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
            System.out.println("Failed to export flat " + filePath + " from " + mf.source);
            e.printStackTrace();
        }
    }

    private void MusicExport() {
        String path = Settings.getInstance().Get("PathTemporary") + "/music/";
        String filePath = path + mf.outputName;
        this.CreateFolder(path);
        try {
            // MUS is picky, so we're pulling from Wad.
            MUS music = wad.getDataAs(this.mf.inputName, MUS.class);
            music.writeBytes(new FileOutputStream(filePath + ".mus", false));

            //System.out.println("Exported " + filePath + ".mus");
        } catch (IOException e) {
            System.out.println("Failed to export " + filePath + ".mus" + " from " + mf.source);
            //e.printStackTrace();
        }
    }
}
