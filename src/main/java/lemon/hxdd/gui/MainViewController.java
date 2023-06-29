package lemon.hxdd.gui;

import javafx.application.Platform;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.VBox;
import javafx.stage.DirectoryChooser;
import javafx.stage.FileChooser;
import javafx.stage.Stage;
import javafx.util.Pair;
import javafx.util.StringConverter;
import lemon.hxdd.Application;
import lemon.hxdd.shared.WADHash;

import java.awt.*;
import java.io.*;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class MainViewController {
    Application mainApp;

    private Stage stage;

    @FXML
    private VBox fpSetup;
    @FXML
    private FlowPane fpProgress;
    @FXML
    private VBox fpComplete;
    @FXML
    private VBox fpInformation;
    @FXML
    private FlowPane fpAbout;

    @FXML
    private Button btnStart;
    @FXML
    private Label labelVersion;

    @FXML
    private Label labelCurrent;
    @FXML
    private Label labelStage;

    @FXML
    private ProgressBar pbCurrent;

    @FXML
    private Label labelPathGZDOOM;
    @FXML
    public Button btnHeretic;
    @FXML
    public Label labelVersionHeretic;
    public Label labelPathHeretic;
    public Button btnHexen;
    @FXML
    public Label labelVersionHexen;
    public Label labelPathHexen;
    public Button btnHexenDD;
    @FXML
    public Label labelVersionHexenDD;
    public Label labelPathHexenDD;

    public Button btnHexenII_PAK0;
    public Label labelPathHexenII_PAK0;
    public Button btnHexenII_PAK1;
    public Label labelPathHexenII_PAK1;
    public Button btnHexenII_PAK2;
    public Label labelPathHexenII_PAK2;
    public Button btnHexenII_PAK3;
    public Label labelPathHexenII_PAK3;
    public Button btnHexenII_PAK4;
    public Label labelPathHexenII_PAK4;

    @FXML
    public ChoiceBox<ChoiceBoxItem> cbTitleScreen;
    public ChoiceBox<ChoiceBoxItem> cbTitleMusic;
    public ChoiceBox<ChoiceBoxItem> cbKoraxLocale;
    public CheckBox cxDownloadTitleSteam;
    public CheckBox cxEnableHexenII;
    @FXML
    public Button btnOpenFolder;

    public Button btnAbout;
    public Hyperlink hplGithub;
    public Hyperlink hplDoomStruct;
    public Hyperlink hplZip;
    public Hyperlink hplNoesis;
    public Hyperlink hplSteam;
    public Hyperlink hplGOG;

    private Map<String, Label[]> labelLookup = new HashMap<>();

    public void SetApplication(Application app) {
        this.mainApp = app;
    }

    public void SetStage(Stage mainStage) {
        this.stage = mainStage;
    }

    public void ShowSetup() {
        this.fpSetup.setVisible(true);
        this.fpProgress.setVisible(false);
        this.fpComplete.setVisible(false);
        this.fpInformation.setVisible(false);
    }
    public void ShowProgress() {
        this.fpSetup.setVisible(false);
        this.fpProgress.setVisible(true);
        this.fpComplete.setVisible(false);
        this.fpInformation.setVisible(false);
    }
    public void ShowComplete() {
        this.fpSetup.setVisible(false);
        this.fpProgress.setVisible(false);
        this.fpComplete.setVisible(true);
        this.fpInformation.setVisible(false);
    }
    public void ShowAbout() {
        this.fpSetup.setVisible(false);
        this.fpProgress.setVisible(false);
        this.fpComplete.setVisible(false);
        this.fpInformation.setVisible(true);
    }

    public void SetVersionLabel(String text) {
        this.labelVersion.setText(text);
    }

    public void SetCurrentLabel(String text) {
        Platform.runLater(() -> {
            this.labelCurrent.setText(text);
        });
    }
    public void SetStageLabel(String text) {
        Platform.runLater(() -> {
            this.labelStage.setText(text);
        });
    }

    public void SetCurrentProgress(double percent) {
        Platform.runLater(() -> {
            this.pbCurrent.setProgress(percent);
        });
    }

    public void SetupView() {
        this.labelLookup.put("HERETIC", new Label[]{labelVersionHeretic, labelPathHeretic});
        this.labelLookup.put("HEXEN", new Label[]{labelVersionHexen, labelPathHexen});
        this.labelLookup.put("HEXDD", new Label[]{labelVersionHexenDD, labelPathHexenDD});
        this.labelLookup.put("HEXENII_PAK0", new Label[]{labelPathHexenII_PAK0});
        this.labelLookup.put("HEXENII_PAK1", new Label[]{labelPathHexenII_PAK1});
        this.labelLookup.put("HEXENII_PAK3", new Label[]{labelPathHexenII_PAK3});
        this.labelLookup.put("HEXENII_PAK4", new Label[]{labelPathHexenII_PAK4});

        labelPathGZDOOM.setText(GetFilePathOrDefaultLabel("PATH_GZDOOM", "Select GZDOOM Folder"));

        CheckWADAndSetLabels("HERETIC", WADHash.GAME_TYPE.HERETIC);
        CheckWADAndSetLabels("HEXEN", WADHash.GAME_TYPE.HEXEN);
        CheckWADAndSetLabels("HEXDD", WADHash.GAME_TYPE.HEXDD);
        CheckPAKAndSetLabels("HEXENII_PAK0");
        CheckPAKAndSetLabels("HEXENII_PAK1");
        CheckPAKAndSetLabels("HEXENII_PAK3");
        CheckPAKAndSetLabels("HEXENII_PAK4");

        BindWADButtons();
        BindPAKButtons();
        BindOpenFolderButton();

        BindCheckBox("OPTION_USE_STEAM_ARTWORK",cxDownloadTitleSteam);
        BindCheckBox("OPTION_ENABLE_HX2", cxEnableHexenII);

        SetupChoiceBoxTitleScreen();
        SetupChoiceBoxTitleMusic();
        SetupChoiceBoxKoraxLocalization();

        BindHyperlinkURL(hplGithub);
        BindHyperlinkURL(hplDoomStruct);
        BindHyperlinkURL(hplZip);
        BindHyperlinkURL(hplNoesis);
        BindHyperlinkURL(hplSteam);
        BindHyperlinkURL(hplGOG);
    }

    protected void SetupChoiceBoxTitleScreen() {
        ObservableList<ChoiceBoxItem> list = FXCollections.observableArrayList(
                new ChoiceBoxItem("Heretic", "heretic"),
                new ChoiceBoxItem("Heretic: Shadow", "heretic.shadow"),
                new ChoiceBoxItem("Hexen", "hexen"),
                new ChoiceBoxItem("Hexen: Deathkings", "hexen.deathkings")
        );
        if (this.mainApp.GetSettings().Get("OPTION_USE_STEAM_ARTWORK").equals("true")) {
            list.add(new ChoiceBoxItem("Hexen II", "hexen2"));
        } else if (this.mainApp.GetSettings().Get("OPTION_TITLE_ARTWORK").equals("hexen2")) {
            this.mainApp.GetSettings().Set("OPTION_TITLE_ARTWORK", "heretic");
        }
        SetChoiceBoxBindings("OPTION_TITLE_ARTWORK", "heretic", cbTitleScreen, list);
    }

    protected void SetupChoiceBoxTitleMusic() {
        ObservableList<ChoiceBoxItem> list = FXCollections.observableArrayList(
                new ChoiceBoxItem("Heretic", "heretic"),
                new ChoiceBoxItem("Hexen", "hexen")
        );
        if (this.mainApp.GetSettings().Get("OPTION_ENABLE_HX2").equals("true")) {
            list.add(new ChoiceBoxItem("Hexen II", "hexen2"));
        } else if (this.mainApp.GetSettings().Get("OPTION_TITLE_MUSIC").equals("hexen2")) {
            this.mainApp.GetSettings().Set("OPTION_TITLE_MUSIC", "heretic");
        }
        SetChoiceBoxBindings("OPTION_TITLE_MUSIC", "heretic", cbTitleMusic, list);
    }
    protected void SetupChoiceBoxKoraxLocalization() {
        ObservableList<ChoiceBoxItem> list = FXCollections.observableArrayList(
                new ChoiceBoxItem("English (Default)", "en"),
                new ChoiceBoxItem("French", "fr"),
                new ChoiceBoxItem("German", "de"),
                new ChoiceBoxItem("Japanese", "jp")
        );
        SetChoiceBoxBindings("OPTION_KORAX_LOCALE", "en", cbKoraxLocale, list);
    }

    protected void SetChoiceBoxBindings(String key, String default_value, ChoiceBox<ChoiceBoxItem> cb, ObservableList<ChoiceBoxItem> list) {
        cb.setItems(list);
        cb.setConverter(new StringConverter<ChoiceBoxItem>() {
            @Override
            public String toString(ChoiceBoxItem object) {
                if (object != null) {
                    return object.GetLabel();
                }
                return "";
            }

            @Override
            public ChoiceBoxItem fromString(String string) {
                return null;
            }
        });
        cb.valueProperty().addListener((obs, oldVal, newVal) -> {
            this.mainApp.GetSettings().Set(key, newVal.GetValue());
        });
        String current = this.mainApp.GetSettings().Get(key);
        list.forEach((item) -> {
            if (current.equals(item.GetValue())) {
                cb.setValue(item);
            }
        });
    }

    protected void BindCheckBox(String key, CheckBox cx) {
        cx.selectedProperty().addListener(new ChangeListener<Boolean>() {
            @Override
            public void changed(ObservableValue<? extends Boolean> observable, Boolean oldValue, Boolean newValue) {
                HandleCheckBox(key, newValue);
            }
        });
        boolean state = Objects.equals(this.mainApp.GetSettings().Get(key), "true");
        cx.setSelected(state);
    }

    protected void BindHyperlinkURL(Hyperlink hpl) {
        hpl.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
                try {
                    // real lazy implementation
                    URI uri = new URI(hpl.getText());
                    Desktop.getDesktop().browse(uri);
                } catch (IOException | URISyntaxException ex) {
                    throw new RuntimeException(ex);
                }
            }
        });
    }

    protected void HandleCheckBox(String key, Boolean newValue) {
        this.mainApp.GetSettings().Set(key, newValue ? "true" : "false");
        ChoiceBox cb = null;
        if (key.equals("OPTION_USE_STEAM_ARTWORK")) {
            cb = cbTitleScreen;
        } else if (key.equals("OPTION_ENABLE_HX2")) {
            cb = cbTitleMusic;
        }

        if (!Objects.equals(cb, null)) {
            ObservableList<ChoiceBoxItem> list = cb.getItems();
            if (newValue) {
                list.add(new ChoiceBoxItem("Hexen II", "hexen2"));
            } else {
                if (cb.getValue().equals(list.get(list.size() - 1))) {
                    cb.setValue(list.get(0));
                }
                list.remove(list.size() - 1);
            }
            cb.setItems(list);
        }
    }


    protected void BindWADButtons() {
        EventHandler<ActionEvent> handler = new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent actionEvent) {
                actionEvent.consume();

                Button source = (Button)actionEvent.getSource();
                String id = source.getId();
                switch(id) {
                    case "btnHeretic": {
                        onButtonClick_SelectPath("Heretic", WADHash.GAME_TYPE.HERETIC);
                        break;
                    }
                    case "btnHexen": {
                        onButtonClick_SelectPath("Hexen", WADHash.GAME_TYPE.HEXEN);
                        break;
                    }
                    case "btnHexenDD": {
                        onButtonClick_SelectPath("HexDD", WADHash.GAME_TYPE.HEXDD);
                        break;
                    }
                }
            }
        };
        btnHeretic.setOnAction(handler);
        btnHexen.setOnAction(handler);
        btnHexenDD.setOnAction(handler);
    }

    protected void BindPAKButtons() {
        EventHandler<ActionEvent> handler = new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent actionEvent) {
                actionEvent.consume();

                Button source = (Button)actionEvent.getSource();
                String id = source.getId();
                switch(id) {
                    case "btnHexenII_PAK0": {
                        onButtonClick_SelectPath_HEXENIIPAK(labelPathHexenII_PAK0, 0);
                        break;
                    }
                    case "btnHexenII_PAK1": {
                        onButtonClick_SelectPath_HEXENIIPAK(labelPathHexenII_PAK1, 1);
                        break;
                    }
                    case "btnHexenII_PAK3": {
                        onButtonClick_SelectPath_HEXENIIPAK(labelPathHexenII_PAK3, 3);
                        break;
                    }
                    case "btnHexenII_PAK4": {
                        onButtonClick_SelectPath_HEXENIIPAK(labelPathHexenII_PAK4, 4);
                        break;
                    }
                }
            }
        };
        btnHexenII_PAK0.setOnAction(handler);
        btnHexenII_PAK1.setOnAction(handler);
        btnHexenII_PAK3.setOnAction(handler);
        btnHexenII_PAK4.setOnAction(handler);
    }

    protected void BindOpenFolderButton() {
        btnOpenFolder.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent actionEvent) {
                Desktop desktop = Desktop.getDesktop();
                try {
                    desktop.open(new File("./"));
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }
        });
    }


    // TODO: Needs to search folder for exe and files
    @FXML
    protected void onButtonClick_SelectPath_GZDOOM() {
        String storedPath = this.mainApp.GetSettings().Get("PATH_GZDOOM");
        if (storedPath.equals("")) {
            storedPath = "./";
        }
        DirectoryChooser chooser = new DirectoryChooser();
        chooser.setInitialDirectory(new File(storedPath));
        chooser.setTitle("Select GZDOOM Folder");

        File selected = chooser.showDialog(this.stage);
        if (selected != null) {
            String path = selected.getAbsolutePath();

            boolean hasBrightmaps = new File(path + "/brightmaps.pk3").isFile();
            boolean hasGamesupport = new File(path + "/game_support.pk3").isFile();
            boolean hasGameWSGFX = new File(path + "/game_widescreen_gfx.pk3").isFile();
            boolean hasGZDoom = new File(path + "/gzdoom.pk3").isFile();
            boolean hasLights = new File(path + "/lights.pk3").isFile();
            if (hasBrightmaps && hasGamesupport && hasGameWSGFX && hasGZDoom && hasLights) {
                this.mainApp.GetSettings().Set("Path_GZDOOM", path);
                labelPathGZDOOM.setText(path);
                System.out.println("GZDOOM Path: " + path);
            } else {
                String missingFiles = "Selected GZDOOM directory is missing the following files:\n";
                if (!hasGZDoom) {
                    missingFiles += " ● gzdoom.pk3,\n";
                }
                if (!hasBrightmaps) {
                    missingFiles += " ● brightmaps.pk3,\n";
                }
                if (!hasGamesupport) {
                    missingFiles += " ● game_support.pk3,\n";
                }
                if (!hasGameWSGFX) {
                    missingFiles += " ● game_widescreen_gfx.pk3,\n";
                }
                if (!hasLights) {
                    missingFiles += " ● lights.pk3";
                }
                DisplayAlertGZDOOM(missingFiles);
            }

        }
    }
    protected void onButtonClick_SelectPath(String name, WADHash.GAME_TYPE gameType) {
        String key = name.toUpperCase();
        String keyPath = String.format("PATH_%s", key);
        File storedPath = GetPathOrGZDOOM(keyPath);
        File selected = OpenFileDialog(storedPath, "Select " + name + " WAD File",  name + " WAD File (*.wad)", "*.wad");
        if (selected != null) {
            String path = selected.getAbsolutePath();
            boolean success = CheckWADAndSetLabels(key, path, gameType);
            if (success) {
                this.mainApp.GetSettings().Set(keyPath, selected.getAbsolutePath());
            } else {
                DisplayAlert(selected, name);
            }
        }
    }

    protected boolean CheckWADAndSetLabels(String key, WADHash.GAME_TYPE gameType) {
        File target = GetPathOrGZDOOM(String.format("PATH_%s", key));
        String path = target.getAbsolutePath();
        return CheckWADAndSetLabels(key, path, gameType);
    }
    protected boolean CheckWADAndSetLabels(String key, String path, WADHash.GAME_TYPE gameType) {
        File target = GetPathOrGZDOOM(String.format("PATH_%s", key));
        //String path = target.getAbsolutePath();

        Pair<Integer, String> result = CheckWAD(gameType, path);
        boolean success = (result != null);
        if (success) {
            Label[] labels = this.labelLookup.get(key);
            labels[0].setText(String.format("%s %s", key.toUpperCase(), result.getValue()));
            labels[1].setText(GetFileNameFromPath(path));

            Tooltip tt = new Tooltip();
            tt.setText(path);
            labels[1].setTooltip(tt);
        }
        return success;
    }
    protected boolean CheckPAKAndSetLabels(String key) {
        File target = GetPathOrGZDOOM(String.format("PATH_%s", key));

        boolean success = PAKFileHasHeaders(target);
        if (success) {
            Label[] labels = this.labelLookup.get(key);
            labels[0].setText(GetFileNameFromPath(target.getAbsolutePath()));

            Tooltip tt = new Tooltip();
            tt.setText(target.getAbsolutePath());
            labels[0].setTooltip(tt);
        }
        return success;
    }


    @FXML
    protected void onButtonClick_SelectPath_HEXENIIPAK(Label lbl, int id) {
        String filename_long = String.format("pak%d.pak",id);
        String key = String.format("HEXENII_PAK%d", id);
        String keyPath = String.format("PATH_%s", key);
        File storedPath = GetPathOrGZDOOM(keyPath);
        File selected = OpenFileDialog(storedPath, "Select Hexen II pak0.pak File",  filename_long, filename_long);
        if (selected != null) {
            boolean success = CheckPAKAndSetLabels(key);
            if (success) {
                this.mainApp.GetSettings().Set(keyPath, selected.getAbsolutePath());
                System.out.println(keyPath + " " + selected.getAbsolutePath());
            } else {
                DisplayAlert(selected, filename_long);
            }
        }
    }

    @FXML
    protected void onButtonClick_Start() {
        this.mainApp.BuildPK3();
    }
    @FXML
    protected void onButtonClick_About() {
        this.ShowAbout();
    }
    @FXML
    protected void onButtonClick_Back() {
        this.ShowSetup();
    }

    protected File GetPathOrGZDOOM(String key) {
        String storedPath = this.mainApp.GetSettings().Get(key);
        if (storedPath.equals("")) {
            String pathGZDOOM = this.mainApp.GetSettings().Get("PATH_GZDOOM");
            if (!pathGZDOOM.equals("")) {
                storedPath = pathGZDOOM;
            } else {
                storedPath = "./";
            }
        }
        return new File(storedPath);
    }

    protected File OpenFileDialog(File path, String title, String fileTypeDescription, String targetExtension) {
        FileChooser.ExtensionFilter ext = new FileChooser.ExtensionFilter(fileTypeDescription, targetExtension);
        FileChooser chooser = new FileChooser();

        File targetPath;
        if (path.exists() && path.isFile()) {
            targetPath = new File(path.getParent());
        } else {
            targetPath = path;
        }

        chooser.setTitle(title);
        chooser.getExtensionFilters().add(ext);
        chooser.setInitialDirectory(targetPath);

        return chooser.showOpenDialog(this.stage);
    }

    protected String GetFileNameFromPath(String path) {
        File f = new File(path);
        return f.getName();
    }

    protected boolean FilePathExists(String path) {
        File fPath = new File(path);
        return fPath.exists();
    }

    protected String GetFilePathOrDefaultLabel(String key, String defaultText) {
        String path = this.mainApp.GetSettings().Get(key);
        if (!path.equals("") && FilePathExists(path)) {
            File pf = new File(path);
            if (pf.isFile()) {
                return GetFileNameFromPath(path);
            }

            return path;
        }
        return defaultText;
    }

    // Can't find a list of known Hexen II PAK MD5s, so we're just checking for headers.
    protected boolean PAKFileHasHeaders(File target) {
        try {
            FileInputStream fIn = new FileInputStream(target);
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
            throw new RuntimeException(e);
        }
    }

    protected Pair<Integer, String> CheckWAD(WADHash.GAME_TYPE gameType, String path) {
        WADHash hf = new WADHash(gameType, path);
        return hf.Compute();
    }

    protected void DisplayAlertGZDOOM(String message) {
        String title = "GZDOOM Missing Files";
        this.mainApp.DisplayAlert(title, message);
    }

    protected void DisplayAlert(File f, String wadName) {
        String fileName = f.getName();
        String title = "WAD File Error";
        String message = String.format("The file %s does not match any known %s wad.\nIf your wad file has been modified, please reinstall from the original source and try again.", fileName, wadName);
        this.mainApp.DisplayAlert(title, message);
    }

    protected void DisplayAlertPAK(File f, String wadName) {
        String fileName = f.getName();
        String title = "PAK File Error";
        String message = String.format("The headers for file %s do not match Hexen II's PAK files.", fileName);
        this.mainApp.DisplayAlert(title, message);
    }
}