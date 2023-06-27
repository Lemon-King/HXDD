package lemon.hxdd.shared;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class PAKTest {
    public boolean Test(String path) {
        File f = new File(path);
        try (FileInputStream fIn = new FileInputStream(path)) {
            if (fIn.available() <= 0x36) {
                return false;
            }
            byte[] binHeader = fIn.readNBytes(4);
            String header = new String(binHeader);

            fIn.skip(0x2C);
            byte[] binData = fIn.readNBytes(4);
            String headerData = new String(binData);

            return header.equals("PACK") && headerData.equals("data");
        } catch (IOException e) {
            System.out.println("PAKTest: Failed to test file " + path);
        }
        return false;
    }
}
