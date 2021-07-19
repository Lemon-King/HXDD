package lemon.hxdd;

import org.zeroturnaround.zip.ZipEntryCallback;
import org.zeroturnaround.zip.ZipUtil;

import java.io.*;
import java.net.URISyntaxException;
import java.util.*;
import java.util.zip.ZipEntry;

// No way I'm writing out all those Heretic and Hexen Actors
// Automate creation of Game Unique MapInfo DoomEdNums and SpawnNums.
// TODO: Add Mapper Compatible IDs
public class ActorFactory {
    private static List<String> TypeOrder = Arrays.asList("doomednums", "spawnnums");
    private static List<String> GameOrder = Arrays.asList("heretic", "hexen");

    public void Create() {
        String path = Settings.getInstance().Get("PathTemporary") + "/zscript/actors/hxdd/";
        File dirFile = new File(path + "spawners");
        if (!dirFile.exists()) {
            dirFile.mkdirs();
        }

        // Merge DoomEdNums and SpawnNums
        TypeOrder.forEach((type) -> {
            // 0 = heretic, 1 = hexen
            List<Properties> lists = new ArrayList<>(Collections.emptyList());
            GameOrder.forEach((game) -> {
                System.out.println("Creating " + game + "." + type + " actors");
                // Properties matches GZDOOM's format and does the job.
                Properties p = new Properties();
                String filePath = "gameinfo/" + type + "." + game;

                try {
                    String protocol = Objects.requireNonNull(this.getClass().getResource("")).getProtocol();
                    if (protocol.equals("jar")) {
                        File jarHXDD = new File(lemon.hxdd.Application.class.getProtectionDomain().getCodeSource().getLocation().toURI());
                        ZipUtil.iterate(jarHXDD, new ZipEntryCallback() {
                            public void process(InputStream in, ZipEntry zipEntry) throws IOException {
                                if (zipEntry.getName().startsWith(filePath)) {
                                    p.load(in);
                                }
                            }
                        });
                    } else if (protocol.equals("file")) {
                        InputStream inputStream = ClassLoader.getSystemResourceAsStream(filePath);
                        p.load(inputStream);
                    }
                } catch (IOException | URISyntaxException e) {
                    e.printStackTrace();
                }
                lists.add(p);
            });

            // Merge Hexen keys with Heretic Keys, if missing add.
            Properties p_hxdd = lists.get(0);
            Properties p_hexen = lists.get(1);
            p_hexen.forEach((k, v) -> {
                String valueHeretic = (String) p_hxdd.get(k);
                String valueHexen = (String) p_hexen.get(k);
                if (valueHexen != null) {
                    if (valueHeretic == null) {
                        p_hxdd.put(k, valueHexen);
                    } else if (!valueHeretic.equals(valueHexen)) {
                        p_hxdd.put(k, valueHeretic + "," + valueHexen);
                    }
                }
            });

            try {
                Map<String, String> actorMap = (Map)p_hxdd;
                SortedSet<String> keys = new TreeSet<>(actorMap.keySet());

                String zscriptActorListFilename = type + "_compat.zs";
                String mapInfoFileName = "mapinfo." + type;

                PrintWriter file_hxdd_actors = new PrintWriter(Settings.getInstance().Get("PathTemporary") + "/zscript/actors/hxdd/" + zscriptActorListFilename);
                PrintWriter file_mapinfo = new PrintWriter(Settings.getInstance().Get("PathTemporary") + "/" + mapInfoFileName);

                AddGeneratedByTag(file_hxdd_actors);
                AddGeneratedByTag(file_mapinfo);
                if (type == "doomednums") {
                    file_mapinfo.print("\nDoomEdNums\n");
                } else if (type == "spawnnums") {
                    file_mapinfo.print("\nSpawnNums\n");
                }
                file_mapinfo.print("{\n");
                for (String key : keys) {
                    String value = actorMap.get(key);
                    String[] result = value.split(",");
                    if (result.length > 1) {
                        //System.out.println("ActorFactory: Found shared Actors " + "ID=" + key + " " + result[0] + " " + result[1]);
                        String actorFile = CreateActorFile(type, key, result[0], result[1]);
                        file_hxdd_actors.print("#include \"zscript/actors/hxdd/spawners/" + actorFile + ".zs" + "\"\n");
                        file_mapinfo.print(key + " = " + actorFile + "\n");
                    } else {
                        file_mapinfo.print(key + " = " + value + "\n");
                    }
                }
                file_mapinfo.print("}\n");
                file_mapinfo.close();
                file_hxdd_actors.close();
            } catch (FileNotFoundException ex) {
                // FileNotFoundException catch is optional and can be collapsed
                System.out.println("ActorFactory: gameinfo files not found, skipping");
            }
        });
    }

    private String CreateActorFile(String type, String id, String actorHeretic, String actorHexen) {
        String path = Settings.getInstance().Get("PathTemporary") + "/zscript/actors/hxdd/spawners/";
        try {
            String fileName = type + "_" + id + "_" + actorHeretic + "_" + actorHexen;
            PrintWriter out = new PrintWriter(path + fileName + ".zs");
            AddGeneratedByTag(out);
            out.print("class " + fileName + " : MultiSpawner {\n");
            out.print("    override void Bind() {\n");
            out.print("        self.SpawnSelect = \"GameSelect\";\n");
            out.print("        self.Heretic = \"" + actorHeretic + "\";\n");
            out.print("        self.Hexen = \"" + actorHexen + "\";\n");
            out.print("    }\n");
            out.print("}");
            out.close();
            //System.out.println("ActorFactory: " + fileName + ".zs");
            return fileName;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        return "error.zs";
    }

    public void CreateEditorNums() {
        // For Doom Editors using HXDD combined things as a base

        System.out.println("Creating Heretic & Hexen combined editornums");
        try {
            String editornumsFileName = "mapinfo.editornums";
            PrintWriter writerEditornums = new PrintWriter(Settings.getInstance().Get("PathTemporary") + "/" + editornumsFileName);
            AddGeneratedByTag(writerEditornums);

            TypeOrder.forEach((type) -> {
                if (type == "doomednums") {
                    writerEditornums.print("\nDoomEdNums\n");
                } else if (type == "spawnnums") {
                    writerEditornums.print("\nSpawnNums\n");
                }
                writerEditornums.print("{\n");

                GameOrder.forEach((game) -> {
                    int offset = 0;
                    if (game.equals("heretic")) {
                        if (type.equals("spawnnums")) {
                            offset = 200;
                        } else {
                            offset = 20000;
                        }
                    } else if (game.equals("hexen")) {
                        if (type.equals("spawnnums")) {
                            offset = 400;
                        } else {
                            offset = 30000;
                        }
                    }

                    // Properties matches GZDOOM's format and does the job.
                    Properties p = new Properties();
                    String filePath = "gameinfo/" + type + "." + game;

                    try {
                        String protocol = Objects.requireNonNull(this.getClass().getResource("")).getProtocol();
                        if (protocol.equals("jar")) {
                            File jarHXDD = new File(lemon.hxdd.Application.class.getProtectionDomain().getCodeSource().getLocation().toURI());
                            ZipUtil.iterate(jarHXDD, new ZipEntryCallback() {
                                public void process(InputStream in, ZipEntry zipEntry) throws IOException {
                                    if (zipEntry.getName().startsWith(filePath)) {
                                        p.load(in);
                                    }
                                }
                            });
                        } else if (protocol.equals("file")) {
                            InputStream inputStream = ClassLoader.getSystemResourceAsStream(filePath);
                            p.load(inputStream);
                        }
                    } catch (IOException | URISyntaxException e) {
                        e.printStackTrace();
                    }

                    Map<String, String> actorMap = (Map)p;
                    SortedSet<String> keys = new TreeSet<>(actorMap.keySet());
                    for (String key : keys) {
                        int spawnNum = Integer.parseInt(key) + offset;
                        String value = actorMap.get(key);
                        writerEditornums.print(spawnNum + " = " + value + "\n");
                    }
                });
                writerEditornums.print("}\n");
            });
            writerEditornums.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void AddGeneratedByTag(PrintWriter writer) {
        writer.print("\n//\n// Generated by HXDD\n//\n\n");
    }
}
