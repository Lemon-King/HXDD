package lemon.hxdd;

import org.w3c.dom.*;
import org.xml.sax.SAXException;
import org.zeroturnaround.zip.ZipEntryCallback;
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
    private final String fileName;
    private int frameCounter = 0;

    XMLModelDef(String fileName) {
        this.fileName = fileName;
    }

    public void Parse() {
        try {
            boolean Setting_Coalesced = (boolean) Settings.getInstance().Get("ModelDefCoalesceData");
            String modelDefPath = "modeldef." + this.fileName.toLowerCase().replace(".xml", "");
            if (Setting_Coalesced) {
                modelDefPath = "modeldef.hexen2";
            }
            FileWriter fw = new FileWriter(Settings.getInstance().Get("PathTemporary") + modelDefPath, Setting_Coalesced);
            PrintWriter out = new PrintWriter(fw);

            final String[] filePath = {"hexen2/modeldef/" + this.fileName};
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();

            final Document[] dxml = new Document[1];
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
                Document xml = dxml[0];

                String className = "";
                Element XMDHeader = xml.getDocumentElement();
                if (!XMDHeader.getNodeName().equals("XMLModelDef")) {
                    // Not a valid XMLModelDef file, skip
                    return;
                }
                if (XMDHeader.hasAttribute("class")) {
                    className = XMDHeader.getAttributeNode("class").getValue();
                }

                // All sub model groups
                NodeList groups = xml.getDocumentElement().getChildNodes();
                int groupCount = groups.getLength();

                for (int i = 0; i < groupCount; i++) {
                    if (groups.item(i).getNodeName().equals("Group")) {

                        Node nodeClass = groups.item(i).getAttributes().getNamedItem("class");
                        if (nodeClass != null) {
                            className = nodeClass.getNodeValue();
                            this.frameCounter = 0;  // reset on class change
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
                                    WriteAnimation(out, attributes);
                                    break;
                                case "frame":
                                    SetFrame(attributes);
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
            } catch (IOException | SAXException e) {
                e.printStackTrace();
            }
        } catch (URISyntaxException | ParserConfigurationException | IOException e) {
            e.printStackTrace();
        }
    }

    private void SetFrame(NamedNodeMap attributes) {
        if (attributes.getNamedItem("index") != null) {
            this.frameCounter = Integer.parseInt(attributes.getNamedItem("index").getNodeValue());
        } else if (attributes.getNamedItem("skip") != null) {
            this.frameCounter += Integer.parseInt(attributes.getNamedItem("skip").getNodeValue());
        }
    }
    private void WriteHeader(PrintWriter out, String className) {
        out.print("Model " + className + " {\n");
    }
    private void WritePath(PrintWriter out, NamedNodeMap attributes) {
        String folder = attributes.getNamedItem("folder").getNodeValue();
        out.print(Shared.TAB_SPACE + "Path " + "\"" + folder + "\"\n");
    }
    private void WriteModel(PrintWriter out, NamedNodeMap attributes) {
        // Model # "file.ext"
        String model = attributes.getNamedItem("model").getNodeValue();
        String file = attributes.getNamedItem("file").getNodeValue();
        out.print(Shared.TAB_SPACE + "Model " + model + " \"" + file + "\"\n");
    }
    private void WriteSkin(PrintWriter out, NamedNodeMap attributes) {
        // Skin # "file.ext"
        String model = attributes.getNamedItem("model").getNodeValue();
        String file = attributes.getNamedItem("file").getNodeValue();
        out.print(Shared.TAB_SPACE + "Skin " + model + " \"" + file + "\"\n");
    }
    private void WriteKeyValue(PrintWriter out, String key, NamedNodeMap attributes) {
        String value = attributes.getNamedItem("value").getNodeValue();
        out.print(Shared.TAB_SPACE + key + " " + value + "\n");
    }
    private void WriteFlag(PrintWriter out, NamedNodeMap attributes) {
        String name = attributes.getNamedItem("name").getNodeValue();
        out.print(Shared.TAB_SPACE + name + "\n");
    }
    private void WriteAnimation(PrintWriter out, NamedNodeMap attributes) {
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

        int frameStart = this.frameCounter;
        int charIndex = charIndexOffset;
        for (int i = 0; i < frames; i++) {
            int frame = this.frameCounter++;
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
        int frameEnd = this.frameCounter - 1;

        out.print(animationLetterFrames + "\n");
        out.printf(Shared.TAB_SPACE + "// " + "Frames: %d - %d\n", frameStart, frameEnd);
        for (String s : buffer) {
            out.print(s);
        }
    }

    private String GetCharFromInt(int i) {
        return String.valueOf((char)(i + 65));
    }
}
