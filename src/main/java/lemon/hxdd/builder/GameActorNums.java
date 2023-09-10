package lemon.hxdd.builder;

import lemon.hxdd.Application;
import org.json.JSONArray;
import org.json.JSONObject;
import org.zeroturnaround.zip.ZipEntryCallback;
import org.zeroturnaround.zip.ZipUtil;

import java.io.*;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.zip.ZipEntry;

// Automate creation of Game Unique MapInfo DoomEdNums and SpawnNums.
public class GameActorNums {
    String pathTemp;

    private static final List<String> TypeOrder = Arrays.asList("doomednums", "spawnnums");
    private static final List<String> GameOrder = Arrays.asList("heretic", "hexen", "doom");

    GameActorNums(String pathTemp) {
        this.pathTemp = pathTemp;
    }

    public void Create() {
        // Merge DoomEdNums and SpawnNums
        ResourceWalker rw;
        try {
            rw = new ResourceWalker("gameinfo");
        } catch (URISyntaxException | IOException e) {
            throw new RuntimeException(e);
        }

        TypeOrder.forEach((type) -> {
            // 0 = heretic, 1 = hexen
            List<Properties> lists = new ArrayList<>(Collections.emptyList());
            GameOrder.forEach((game) -> {
                //System.out.println("Creating " + game + "." + type + " actors");
                // Properties matches GZDOOM's format and does the job.
                Properties p = new Properties();
                String filePath = "gameinfo/" + type + "." + game;
                for (int i = 0; i < rw.files.size(); i++) {
                    if (rw.files.get(i).getKey().endsWith(game)) {
                        try {
                            InputStream in = Application.class.getResourceAsStream(filePath);
                            p.load(in);
                            in.close();
                        } catch (IOException e) {
                            throw new RuntimeException(e);
                        }
                    }
                }

                lists.add(p);
            });

            // Merge Hexen keys with Heretic Keys, if missing add.
            Properties p_hxdd = new Properties();
            Properties p_heretic = lists.get(0);
            Properties p_hexen = lists.get(1);
            Properties p_doom = lists.get(2);
            SortedSet<String> actorKeys = new TreeSet<>();
            for (int i = 0; i < lists.size(); i++) {
                lists.get(i).forEach((k,v) -> {
                    if(!actorKeys.equals(k)) {
                        actorKeys.add((String) k);
                    }
                });
            }

            JSONArray actorsJSON = new JSONArray();
            actorKeys.forEach((key) -> {
                JSONObject lutActors = new JSONObject();
                String valueHeretic = (String) p_heretic.get(key);
                String valueHexen = (String) p_hexen.get(key);
                String valueDoom = (String) p_doom.get(key);      // pwad mode, NYI
                if (valueDoom != null) {
                    lutActors.put("Doom", valueDoom);
                }
                if (valueHeretic != null) {
                    lutActors.put("Heretic", valueHeretic);
                }
                if (valueHexen != null) {
                    lutActors.put("Hexen", valueHexen);
                }
                if (!lutActors.isEmpty()) {
                    actorsJSON.put(lutActors);
                }

                String newValue = valueHexen;
                if (newValue == null) {
                    newValue = valueHeretic;
                }
                if (newValue == null) {
                    newValue = valueDoom;
                }
                if (newValue != null) {
                    p_hxdd.put(key, newValue);
                }
            });
            CreateXGT(actorsJSON, type);

            try {
                Map<String, String> actorMap = (Map)p_hxdd;
                SortedSet<String> keys = new TreeSet<>(actorMap.keySet());

                String zscriptActorListFilename = type + "_compat.zs";
                String mapInfoFileName = "mapinfo." + type;

                //PrintWriter file_hxdd_actors = new PrintWriter(Settings.getInstance().Get("PathTemporary") + "/zscript_generated/actors/hxdd/" + zscriptActorListFilename);
                PrintWriter file_mapinfo = new PrintWriter(this.pathTemp + "/" + mapInfoFileName);

                //AddGeneratedByTag(file_hxdd_actors);
                AddGeneratedByTag(file_mapinfo);
                if (type == "doomednums") {
                    file_mapinfo.print("\nDoomEdNums\n");
                } else if (type == "spawnnums") {
                    file_mapinfo.print("\nSpawnNums\n");
                }
                file_mapinfo.print("{\n");
                for (String key : keys) {
                    String value = actorMap.get(key);
                    //String[] result = value.split(",");
                    //if (result.length > 1) {
                    //System.out.println("GameActorNums: Found shared Actors " + "ID=" + key + " " + result[0] + " " + result[1]);
                    //String actorFile = CreateActorFile(type, key, result[0], result[1]);
                    //file_hxdd_actors.print("#include \"zscript_generated/actors/hxdd/spawners/" + actorFile + ".zs" + "\"\n");
                    //file_mapinfo.print(key + " = " + actorFile + "\n");
                    //} else {
                    file_mapinfo.print(key + " = " + value + "\n");
                    //}
                }
                file_mapinfo.print("}\n");
                file_mapinfo.close();
                //file_hxdd_actors.close();

            } catch (FileNotFoundException ex) {
                // FileNotFoundException catch is optional and can be collapsed
                System.out.println("GameActorNums: gameinfo files not found, skipping");
            }
        });
    }

    private void CreateXGT(JSONArray list, String type) {
        String path = this.pathTemp + "/xgt";
        File dirFile = new File(path);
        if (!dirFile.exists()) {
            dirFile.mkdirs();
        }

        try {
            PrintWriter out = new PrintWriter(path + "/" + type + ".xgt");
            out.print(list);
            out.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }

    private String CreateActorFile(String type, String id, String actorHeretic, String actorHexen) {
        String path = this.pathTemp + "/zscript_generated/actors/hxdd/spawners/";
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
            //System.out.println("GameActorNums: " + fileName + ".zs");
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
            PrintWriter writerEditornums = new PrintWriter(this.pathTemp + "/" + editornumsFileName);
            AddGeneratedByTag(writerEditornums);

            AtomicInteger nextId = new AtomicInteger();
            TypeOrder.forEach((type) -> {
                if (Objects.equals(type, "doomednums")) {
                    nextId.set(11000);
                    writerEditornums.print("\nDoomEdNums\n");
                } else if (Objects.equals(type, "spawnnums")) {
                    nextId.set(200);
                    writerEditornums.print("\nSpawnNums\n");
                }
                writerEditornums.print("{\n");

                GameOrder.forEach((game) -> {
                    // Properties matches GZDOOM's format and does the job.
                    Properties p = new Properties();
                    String filePath = "gameinfo/" + type + "." + game;

                    try {
                        URL res = Application.class.getResource("");
                        if (res != null) {
                            if (res.equals("jar")) {
                                File jarHXDD = new File(lemon.hxdd.Application.class.getProtectionDomain().getCodeSource().getLocation().toURI());
                                ZipUtil.iterate(jarHXDD, new ZipEntryCallback() {
                                    public void process(InputStream in, ZipEntry zipEntry) throws IOException {
                                        if (zipEntry.getName().startsWith(filePath)) {
                                            p.load(in);
                                        }
                                    }
                                });
                            } else if (res.equals("file")) {
                                InputStream inputStream = ClassLoader.getSystemResourceAsStream(filePath);
                                p.load(inputStream);
                            }
                        }
                    } catch (IOException | URISyntaxException e) {
                        e.printStackTrace();
                    }

                    Map<String, String> actorMap = (Map)p;
                    SortedSet<String> keys = new TreeSet<>(actorMap.keySet());
                    for (String key : keys) {
                        int spawnNum = nextId.getAndIncrement();
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
