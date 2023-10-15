package lemon.hxdd.shared;

import javafx.util.Pair;

import java.io.*;
import java.security.DigestInputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Formatter;
import java.util.HashMap;
import java.util.Map;

// Hash lookups found at: https://github.com/Doom-Utils/iwad-patches/tree/master

public class WADHash {
    public enum GAME_TYPE {
        HERETIC,
        HEXEN,
        HEXDD,
        HEXENII
    }
    public enum HERETIC_VERSIONS {
        V10,
        V12,
        V13
    }
    public enum HEXEN_VERSIONS {
        V10,
        V11,
        V11_MACOS,
        BETA
    }
    public enum HEXDD_VERSIONS {
        V10,
        V11
    }

    // https://github.com/Doom-Utils/iwad-patches/tree/master/heretic.wad
    static String Heretic_v10 = "b5a6cc79cde48d97905b44282e82c4c966a23a87";
    static String Heretic_v12 = "a54c5d30629976a649119c5ce8babae2ddfb1a60";
    static String Heretic_v13 = "f489d479371df32f6d280a0cb23b59a35ba2b833";

    // https://github.com/Doom-Utils/iwad-patches/tree/master/hexen.wad
    static String Hexen_Beta = "ae797f5fdce845be24a7a24dd5bfc3e762a17bbe";  // Pre-release version
    static String Hexen_v10 = "ac129c4331bf26f0f080c4a56aaa40d64969c98a";
    static String Hexen_v11 = "4b53832f0733c1e29e5f1de2428e5475e891af29";
    static String Hexen_MacOS = "4343fbe5aef905ef6d077a1517a50c919e5cc906";   // version v1.1 with MacOS High Res assets

    // https://github.com/Doom-Utils/iwad-patches/tree/master/hexdd.wad
    static String HexDD_v10 = "c3065527d62b05a930fe75fe8181a64fb1982976";
    static String HexDD_v11 = "081f6a2024643b54ef4a436a85508539b6d20a1e";

    File file;
    GAME_TYPE type;

    public WADHash(GAME_TYPE gameType, String path) {
        this.type = gameType;
        this.file = new File(path);
    }

    public Pair Compute() {
        Map<String, Pair> versionMap = new HashMap<>();
        if (GAME_TYPE.HERETIC == this.type) {
            versionMap.put(Heretic_v10, new Pair<Enum<HERETIC_VERSIONS>, String>(HERETIC_VERSIONS.V10, "v1.0"));
            versionMap.put(Heretic_v12, new Pair<Enum<HERETIC_VERSIONS>, String>(HERETIC_VERSIONS.V12, "v1.2"));
            versionMap.put(Heretic_v13, new Pair<Enum<HERETIC_VERSIONS>, String>(HERETIC_VERSIONS.V13, "v1.3 Shadows"));
        } else if (GAME_TYPE.HEXEN == this.type) {
            //versionMap.put(Hexen_Beta, new Pair<Enum<HEXEN_VERSIONS>, String>(HEXEN_VERSIONS.BETA, "Beta"));
            versionMap.put(Hexen_MacOS,new Pair<Enum<HEXEN_VERSIONS>, String>(HEXEN_VERSIONS.V11_MACOS, "v1.1 MacOS"));
            versionMap.put(Hexen_v10, new Pair<Enum<HEXEN_VERSIONS>, String>(HEXEN_VERSIONS.V10, "v1.0"));
            versionMap.put(Hexen_v11, new Pair<Enum<HEXEN_VERSIONS>, String>(HEXEN_VERSIONS.V11, "v1.1"));
        } else if (GAME_TYPE.HEXDD == this.type) {
            versionMap.put(HexDD_v10, new Pair<Enum<HEXDD_VERSIONS>, String>(HEXDD_VERSIONS.V10, "v1.0"));
            versionMap.put(HexDD_v11, new Pair<Enum<HEXDD_VERSIONS>, String>(HEXDD_VERSIONS.V11, "v1.1"));
        } else {
            System.out.println("WADHash: Invalid GAME_TYPE!");
            return null;
        }

        try {
            if (this.file.isDirectory()) {
                System.out.println("WADHash: skipping, path is folder.");
                return null;
            }
            InputStream in = new BufferedInputStream(new FileInputStream(file));
            MessageDigest digest = MessageDigest.getInstance("SHA-1");
            DigestInputStream digestStream = new DigestInputStream(in, digest);
            digestStream.readAllBytes();

            MessageDigest msgDigest = digestStream.getMessageDigest();

            byte[] hash = msgDigest.digest();
            digestStream.close();
            in.close();

            String result = byteArray2Hex(hash);

            return versionMap.get(result);
        } catch (NoSuchAlgorithmException | IOException e) {
            System.out.println("WADHash: failed to compute hash " + e.getMessage());
            return null;
        }
    }

    // ref: https://stackoverflow.com/a/1515495
    private static String byteArray2Hex(final byte[] hash) {
        Formatter formatter = new Formatter();
        for (byte b : hash) {
            formatter.format("%02x", b);
        }
        return formatter.toString();
    }
}
