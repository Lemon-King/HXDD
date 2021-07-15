package lemon.hxdd;

public class MetaFile {
    String source;
    String sourcePK3;
    String inputName;
    String outputName;
    String type;
    String folder;
    String decodeType;
    int[] dimensions;

    MetaFile(String name, String folder, String sourceName) {
        this.source = sourceName;   // check if pk3 from filename
        this.sourcePK3 = null;      // PK3 file, overrides wad extract
        this.inputName = name;      // input filename
        this.outputName = name;     // output filename
        this.folder = folder;       // export folder
        this.decodeType = folder;   // decode method
        this.dimensions = null;     // used by fullscreen images
    }
}
