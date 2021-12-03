package lemon.hxdd;

import java.util.Collections;

public class ProgressBar {
    static final String[] CHAR_STATES = {" ", "░","▒","▓","█"};  // 0, 25, 50, 75, 100

    String label;

    ProgressBar(String label) {
        this.label = label;
        System.out.printf("%s:\n", this.label);
        SetPercent((float) 0);
    }

    public void SetPercent(float value) {
        String bar = drawPercentBar(value);
        System.out.printf("%s\r", bar);
        if (value >= 1.0) {
            System.out.print("\n");
        }
    }

    private String drawPercentBar(float value) {
        float pValue = value * 100;
        float blocks = pValue / 5;
        int filled = ((int) Math.floor(blocks));
        float remainder = blocks - filled;
        String blocksFilled = String.join("", Collections.nCopies(filled, "█"));
        String blockActive = value >= 1.0 ? "" : valueToChar(remainder);
        String blockEmpty = filled >= 19 ? "" : String.join("", Collections.nCopies( 19 - filled, " "));
        return String.format("[%s%s%s] %.2f%%", blocksFilled, blockActive, blockEmpty, pValue);
    }

    private String valueToChar(double value) {
        if (value < 0.25) {
            return CHAR_STATES[0];
        } else if (value < 0.50) {
            return CHAR_STATES[1];
        } else if (value < 0.75) {
            return CHAR_STATES[2];
        } else if (value < 1.0) {
            return CHAR_STATES[3];
        } else {
            return CHAR_STATES[4];
        }
    }
}
