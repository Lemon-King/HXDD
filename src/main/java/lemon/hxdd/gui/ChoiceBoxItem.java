package lemon.hxdd.gui;

public class ChoiceBoxItem {
    private String label;
    private String value;

    public String GetLabel() {
        return label;
    }
    public String GetValue() {
        return value;
    }

    public ChoiceBoxItem(String label, String value) {
        this.label = label;
        this.value = value;
    }
}
