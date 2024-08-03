// ref: https://www.gamers.org/dEngine/quake/spec/quake-spec34/qkspec_7.htm

package lemon.hxdd.builder;

import java.io.*;
import java.util.HashMap;
import java.util.Map;

public class Wad2File {
    Wad2Header header;
    public Wad2Entry[] entries;
    public Map<String, Wad2Entry> entryMap = new HashMap<>();
    RandomAccessFile file;

    public static class Wad2Header {
        char[] magic = new char[4]; // "WAD2"
        int numentries;             // Number of entries
        int diroffset;              // Position of WAD directory in file
    }

    public static class Wad2Entry {
        int offset;                 // Position of the entry in WAD
        int dsize;                  // Size of the entry in WAD file
        int size;                   // Size of the entry in memory
        char type;                  // Type of entry
        char cmprs;                 // Compression. 0 if none.
        short dummy;                // Not used
        String name;                // 1 to 16 characters, '\0'-padded
    }

    public static class Wad2Flat {
        int width;                  // Picture width
        int height;                 // Picture height
        byte[] pixels;
    }

    public Wad2File(String path) throws IOException {
        File f = new File(path);
        file = new RandomAccessFile(f, "r");
        readHeader();
        readEntries();
        buildEntryMap();
        file.seek(0);
    }

    public void close() throws IOException {
        file.close();
    }

    private void readHeader() throws IOException {
        file.seek(0);
        header = new Wad2Header();
        byte[] magicBytes = new byte[4];
        file.readFully(magicBytes);
        for (int i = 0; i < 4; i++) {
            header.magic[i] = (char) magicBytes[i];
        }
        String magicString = new String(header.magic);
        if (!magicString.equals("WAD2")) {
            throw new IOException("Invalid WAD2 file");
        }
        header.numentries = Integer.reverseBytes(file.readInt());
        header.diroffset = Integer.reverseBytes(file.readInt());
    }

    private void readEntries() throws IOException {
        file.seek(header.diroffset);
        entries = new Wad2Entry[(int) header.numentries];
        for (int i = 0; i < header.numentries; i++) {
            Wad2Entry entry = new Wad2Entry();
            entry.offset = Integer.reverseBytes(file.readInt());
            entry.dsize = Integer.reverseBytes(file.readInt());
            entry.size = Integer.reverseBytes(file.readInt());
            entry.type = (char) file.readByte();
            entry.cmprs = (char) file.readByte();
            entry.dummy = file.readShort();
            byte[] nameBytes = new byte[16];
            file.readFully(nameBytes);
            entry.name = new String(nameBytes).trim();
            System.out.println(entry.name);
            entries[i] = entry;
        }
    }

    private void buildEntryMap() {
        for (Wad2Entry entry : entries) {;
            entryMap.put(entry.name, entry);
        }
    }

    public Wad2Flat readLumpAsFlat(String lumpName) throws IOException {
        Wad2Entry entry = entryMap.get(lumpName);
        if (entry == null) {
            throw new IllegalArgumentException("Wad2File: Lump not found: " + lumpName);
        }
        file.seek(entry.offset);
        Wad2Flat flat = new Wad2Flat();
        flat.width = Integer.reverseBytes(file.readInt());
        flat.height = Integer.reverseBytes(file.readInt());
        flat.pixels = new byte[(int) entry.size];
        file.readFully(flat.pixels);
        return flat;
    }
}


