package lemon.hxdd.builder;

import javafx.util.Pair;
import lemon.hxdd.Application;
import lemon.hxdd.shared.Util;
import org.w3c.dom.*;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.*;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Objects;

public class XMLModelDef {
    Application app;

    XMLModelDef(Application app) {
        this.app = app;
    }

    public void Generate() {
        final float[] count = {0};
        //ProgressBar p = new ProgressBar("Generating ModelDefs from XMLModelDef");
        this.app.controller.SetStageLabel("Generating ModelDefs from XMLModelDef");
        this.app.controller.SetCurrentProgress(0);

        URL res = this.getClass().getResource("");
        if (res != null) {
            String protocol = res.getProtocol();
            try {
                ResourceWalker rw = new ResourceWalker("pakdata/modeldef");
                for (Pair<String, File> f : rw.files) {
                    Parse(f.getValue(), protocol.equals("jar"));
                    this.app.controller.SetCurrentLabel(f.getValue().getName());
                    this.app.controller.SetCurrentProgress(++count[0] / rw.files.size());
                }
            } catch (URISyntaxException | IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void Parse(File file, boolean buildAsSingleFile) {
        try {
            InputStream in = new FileInputStream(file);

            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();

            Document docXML = dBuilder.parse(in);

            String className = "";
            Element XMDHeader = docXML.getDocumentElement();
            if (!XMDHeader.getNodeName().equals("XMLModelDef")) {
                // Not a valid XMLModelDef file, skip
                return;
            }
            if (XMDHeader.hasAttribute("class")) {
                className = XMDHeader.getAttributeNode("class").getValue();
            }
            if (XMDHeader.hasAttribute("skip")) {
                String value = XMDHeader.getAttributeNode("skip").getValue();
                if (value.equals("true")) {
                    return;
                }
            }


            String modelDefPath = "/modeldef." + file.getName().toLowerCase().replace(".xml", "");
            if (buildAsSingleFile) {
                modelDefPath = "/modeldef.hxdd";
            }
            FileWriter fw = new FileWriter(this.app.settings.GetPath("temp") + modelDefPath, buildAsSingleFile);
            PrintWriter out = new PrintWriter(fw);

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
            in.close();
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
        out.print(Util.TAB_SPACE + "Path " + "\"" + folder + "\"\n");
    }
    private static void WriteModel(PrintWriter out, NamedNodeMap attributes) {
        // Model # "file.ext"
        String model = attributes.getNamedItem("model").getNodeValue();
        String file = attributes.getNamedItem("file").getNodeValue();
        out.print(Util.TAB_SPACE + "Model " + model + " \"" + file + "\"\n");
    }
    private static void WriteSkin(PrintWriter out, NamedNodeMap attributes) {
        // Skin # "file.ext"
        String model = attributes.getNamedItem("model").getNodeValue();
        String file = attributes.getNamedItem("file").getNodeValue();
        out.print(Util.TAB_SPACE + "Skin " + model + " \"" + file + "\"\n");
    }
    private static void WriteKeyValue(PrintWriter out, String key, NamedNodeMap attributes) {
        String value = attributes.getNamedItem("value").getNodeValue();
        out.print(Util.TAB_SPACE + key + " " + value + "\n");
    }
    private static void WriteFlag(PrintWriter out, NamedNodeMap attributes) {
        String name = attributes.getNamedItem("name").getNodeValue();
        out.print(Util.TAB_SPACE + name + "\n");
    }
    private static int WriteAnimation(PrintWriter out, NamedNodeMap attributes, int frameCounter) {
        String key = attributes.getNamedItem("key").getNodeValue();
        int frames = Integer.parseInt(attributes.getNamedItem("frames").getNodeValue());
        int model = Integer.parseInt(attributes.getNamedItem("model").getNodeValue());

        Node nodeComment = attributes.getNamedItem("comment");
        if (nodeComment != null) {
            out.print("\n" + Util.TAB_SPACE + "// " + nodeComment.getNodeValue() + "\n");
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
                animationLetterFrames.append(Util.TAB_SPACE + "// ").append(AnimationId).append(" A");
            } else {
                animationLetterFrames.append(alphaIndexChar);
            }
            buffer.add(Util.TAB_SPACE + "FrameIndex " + AnimationId + " " + alphaIndexChar + " " + model + " " + frame + "\n");
        }

        out.print(animationLetterFrames + "\n");
        out.printf(Util.TAB_SPACE + "// " + "Frames: %d - %d\n", frameStart, frameCounter - 1);
        for (String s : buffer) {
            out.print(s);
        }

        return frameCounter;
    }

    private static String GetCharFromInt(int i) {
        return String.valueOf((char)(i + 65));
    }
}
