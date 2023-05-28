package lemon.hxdd;

import org.w3c.dom.*;
import org.xml.sax.SAXException;
import org.zeroturnaround.zip.ZipEntryCallback;
import org.zeroturnaround.zip.ZipInfoCallback;
import org.zeroturnaround.zip.ZipUtil;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.*;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Objects;
import java.util.zip.ZipEntry;

public class XMLModelDef {
    XMLModelDef() {}

    public void Export() {
        final float[] count = {0};
        ProgressBar p = new ProgressBar("Generating ModelDefs from XMLModelDef");
        String protocol = Objects.requireNonNull(this.getClass().getResource("")).getProtocol();
        try {
            if (protocol.equals("jar")){
                final String prefix = "hexen2/modeldef/";

                ArrayList<String> files = new ArrayList<String>();
                File jarHXDD = new File(lemon.hxdd.Application.class.getProtectionDomain().getCodeSource().getLocation().toURI());

                // Folder size is unknown until we parse it, this is only does for the progress bar
                ZipUtil.iterate(jarHXDD, new ZipInfoCallback() {
                    public void process(ZipEntry zipEntry) throws IOException {
                        if (zipEntry.getName().contains(prefix) && zipEntry.getName().endsWith(".xml")) {
                            files.add(zipEntry.getName());
                        }
                    }
                });
                ZipUtil.iterate(jarHXDD, new ZipEntryCallback() {
                    public void process(InputStream in, ZipEntry zipEntry) throws IOException {
                        if (files.contains(zipEntry.getName())) {
                            String[] pathSplit = zipEntry.getName().split("/");

                            Parse(pathSplit[pathSplit.length - 1], in, protocol.equals("jar"));
                            in.close();
                            p.SetPercent(++count[0] / files.size());
                        }
                    }
                });
            } else if (protocol.equals("file")) {
                File folder = new File("./src/main/resources/hexen2/modeldef/");
                File[] modeldeflist = folder.listFiles();

                if (modeldeflist == null) {
                    System.out.printf("XMLModelDef Error: Folder not found!");
                    return;
                }

                for (File file : modeldeflist) {
                    if (file.isFile()) {
                        InputStream in = new FileInputStream(file);
                        Parse(file.getName(), in, protocol.equals("jar"));
                        in.close();
                        p.SetPercent(++count[0] / modeldeflist.length);
                    }
                }
            } else {
                System.out.println("Failed to export HXDD Assets.");
            }
        } catch (URISyntaxException | IOException e) {
            e.printStackTrace();
        }
    }

    private static void Parse(String fileName, InputStream in, boolean buildAsSingleFile) {
        try {
            String modelDefPath = "modeldef." + fileName.toLowerCase().replace(".xml", "");
            if (buildAsSingleFile) {
                modelDefPath = "modeldef.hexen2";
            }
            FileWriter fw = new FileWriter(Settings.getInstance().Get("PathTemporary") + modelDefPath, buildAsSingleFile);
            PrintWriter out = new PrintWriter(fw);

            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();

            Document docXML = dBuilder.parse(in);
            /*
            try {
                String protocol = Objects.requireNonNull(this.getClass().getResource("")).getProtocol();
                if (protocol.equals("jar")) {
                    File jarHXDD = new File(lemon.hxdd.Application.class.getProtectionDomain().getCodeSource().getLocation().toURI());
                    ZipUtil.iterate(jarHXDD, new ZipEntryCallback() {
                        public void process(InputStream in, ZipEntry zipEntry) throws IOException {
                            if (zipEntry.getName().startsWith(filePath[0])) {
                                try {
                                    dxml[0] = dBuilder.parse(in);
                                } catch (SAXException e) {
                                    e.printStackTrace();
                                }
                            }
                            in.close();
                        }
                    });
                } else if (protocol.equals("file")) {
                    InputStream in = ClassLoader.getSystemResourceAsStream(filePath[0]);
                    dxml[0] = dBuilder.parse(in);
                    assert in != null;
                    in.close();
                }
                Document xml = dxml;
                */

            String className = "";
            Element XMDHeader = docXML.getDocumentElement();
            if (!XMDHeader.getNodeName().equals("XMLModelDef")) {
                // Not a valid XMLModelDef file, skip
                return;
            }
            if (XMDHeader.hasAttribute("class")) {
                className = XMDHeader.getAttributeNode("class").getValue();
            }

            // All sub model groups
            NodeList groups = docXML.getDocumentElement().getChildNodes();
            int groupCount = groups.getLength();

            int frameCounter = 0;

            for (int i = 0; i < groupCount; i++) {
                if (groups.item(i).getNodeName().equals("Group")) {

                    Node nodeClass = groups.item(i).getAttributes().getNamedItem("class");
                    if (nodeClass != null) {
                        className = nodeClass.getNodeValue();
                        frameCounter = 0;  // reset on class change
                    }
                    WriteHeader(out, className);

                    NodeList nodes = groups.item(i).getChildNodes();
                    for (int n = 0; n < nodes.getLength(); n++) {
                        Node cNode = nodes.item(n);
                        String nodeName = cNode.getNodeName().toLowerCase();
                        NamedNodeMap attributes = cNode.getAttributes();

                        switch (nodeName) {
                            case "path":
                                WritePath(out, attributes);
                                break;
                            case "model":
                                WriteModel(out, attributes);
                                break;
                            case "skin":
                                WriteSkin(out, attributes);
                                break;
                            case "flag":
                                WriteFlag(out, attributes);
                                break;
                            case "animation":
                                frameCounter = WriteAnimation(out, attributes, frameCounter);
                                break;
                            case "frame":
                                frameCounter = SetFrame(attributes, frameCounter);
                                break;
                            case "scale":
                                WriteKeyValue(out, "Scale", attributes);
                                break;
                            case "offset":
                                WriteKeyValue(out, "Offset", attributes);
                                break;
                            case "angleoffset":
                                WriteKeyValue(out, "AngleOffset", attributes);
                                break;
                            case "pitchoffset":
                                WriteKeyValue(out, "PitchOffset", attributes);
                                break;
                            case "rolloffset":
                                WriteKeyValue(out, "RollOffset", attributes);
                                break;
                            case "rotation-center":
                                WriteKeyValue(out, "Rotation-Center", attributes);
                                break;
                            case "rotation-speed":
                                WriteKeyValue(out, "Rotation-Speed", attributes);
                                break;
                            case "rotation-vector":
                                WriteKeyValue(out, "Rotation-Vector", attributes);
                                break;
                            case "surface-skin":
                                WriteKeyValue(out, "Surface-Skin", attributes);
                                break;
                            case "zoffset":
                                WriteKeyValue(out, "ZOffset", attributes);
                                break;
                            case "#comment":
                            case "#text":
                                // into the void
                                break;
                            default:
                                System.out.println("Unknown Tag: " + nodeName);
                        }
                    }
                    out.print("}\n");
                }
            }
            out.close();
        } catch (ParserConfigurationException | IOException | SAXException e) {
            e.printStackTrace();
        }
    }

    private static int SetFrame(NamedNodeMap attributes, int frameCounter) {
        if (attributes.getNamedItem("index") != null) {
            frameCounter = Integer.parseInt(attributes.getNamedItem("index").getNodeValue());
        } else if (attributes.getNamedItem("skip") != null) {
            frameCounter += Integer.parseInt(attributes.getNamedItem("skip").getNodeValue());
        }
        return frameCounter;
    }
    private static void WriteHeader(PrintWriter out, String className) {
        out.print("Model " + className + " {\n");
    }
    private static void WritePath(PrintWriter out, NamedNodeMap attributes) {
        String folder = attributes.getNamedItem("folder").getNodeValue();
        out.print(Shared.TAB_SPACE + "Path " + "\"" + folder + "\"\n");
    }
    private static void WriteModel(PrintWriter out, NamedNodeMap attributes) {
        // Model # "file.ext"
        String model = attributes.getNamedItem("model").getNodeValue();
        String file = attributes.getNamedItem("file").getNodeValue();
        out.print(Shared.TAB_SPACE + "Model " + model + " \"" + file + "\"\n");
    }
    private static void WriteSkin(PrintWriter out, NamedNodeMap attributes) {
        // Skin # "file.ext"
        String model = attributes.getNamedItem("model").getNodeValue();
        String file = attributes.getNamedItem("file").getNodeValue();
        out.print(Shared.TAB_SPACE + "Skin " + model + " \"" + file + "\"\n");
    }
    private static void WriteKeyValue(PrintWriter out, String key, NamedNodeMap attributes) {
        String value = attributes.getNamedItem("value").getNodeValue();
        out.print(Shared.TAB_SPACE + key + " " + value + "\n");
    }
    private static void WriteFlag(PrintWriter out, NamedNodeMap attributes) {
        String name = attributes.getNamedItem("name").getNodeValue();
        out.print(Shared.TAB_SPACE + name + "\n");
    }
    private static int WriteAnimation(PrintWriter out, NamedNodeMap attributes, int frameCounter) {
        String key = attributes.getNamedItem("key").getNodeValue();
        int frames = Integer.parseInt(attributes.getNamedItem("frames").getNodeValue());
        int model = Integer.parseInt(attributes.getNamedItem("model").getNodeValue());

        Node nodeComment = attributes.getNamedItem("comment");
        if (nodeComment != null) {
            out.print("\n" + Shared.TAB_SPACE + "// " + nodeComment.getNodeValue() + "\n");
        } else {
            out.print("\n\n");
        }

        int charIndexOffset = 0;
        Node nodeFrameCharOffset = attributes.getNamedItem("framecharoffset");
        if (nodeFrameCharOffset != null) {
            charIndexOffset = Integer.parseInt(nodeFrameCharOffset.getNodeValue());
        }

        ArrayList<String> buffer = new ArrayList<String>();
        StringBuilder animationLetterFrames = new StringBuilder();

        int frameStart = frameCounter;
        int charIndex = charIndexOffset;
        for (int i = 0; i < frames; i++) {
            int frame = frameCounter++;
            int alphaIndex = (int)Math.floor((double)i / 26);
            int animationIndex = alphaIndex % 26;
            String char4 = key.length() == 4 ? "" : GetCharFromInt(animationIndex);
            String AnimationId = key + char4;
            String alphaIndexChar = GetCharFromInt(charIndex++ % 26);

            if (animationLetterFrames.toString().equals("")) {
                animationLetterFrames.append(Shared.TAB_SPACE + "// ").append(AnimationId).append(" A");
            } else {
                animationLetterFrames.append(alphaIndexChar);
            }
            buffer.add(Shared.TAB_SPACE + "FrameIndex " + AnimationId + " " + alphaIndexChar + " " + model + " " + frame + "\n");
        }

        out.print(animationLetterFrames + "\n");
        out.printf(Shared.TAB_SPACE + "// " + "Frames: %d - %d\n", frameStart, frameCounter - 1);
        for (String s : buffer) {
            out.print(s);
        }

        return frameCounter;
    }

    private static String GetCharFromInt(int i) {
        return String.valueOf((char)(i + 65));
    }
}
