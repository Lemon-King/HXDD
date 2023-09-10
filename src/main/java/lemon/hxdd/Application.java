package lemon.hxdd;

import java.awt.*;

import javafx.fxml.FXMLLoader;
import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.scene.control.Alert;
import lemon.hxdd.builder.PackageBuilder;
import lemon.hxdd.gui.MainViewController;
import lemon.hxdd.shared.GITVersion;

import java.io.IOException;
import java.util.Objects;
import java.util.Locale;

public class Application extends javafx.application.Application {
    public AppSettings settings;

    public MainViewController controller;

    Stage appStage;

    PackageBuilder builder;

    @Override
    public void start(Stage stage) throws IOException {
        Locale.setDefault(new Locale("en", "English"));
        GITVersion.getInstance().Initialize();
        String version = GITVersion.getInstance().GetProperties().getProperty("git.closest.tag.name");
        if (Objects.equals(version, "")) {
            version = GITVersion.getInstance().GetProperties().getProperty("git.build.version");
        }

        this.appStage = stage;
        this.settings = new AppSettings();

        this.builder = new PackageBuilder(this);

        FXMLLoader fxmlLoader = new FXMLLoader(Application.class.getResource("main-view.fxml"));
        Scene scene = new Scene(fxmlLoader.load());
        stage.setTitle("HXDD: A Heretic and Hexen Wad Merger!");
        stage.getIcons().add(new Image(Application.class.getResourceAsStream("icon.png")));
        stage.setResizable(false);
        stage.setScene(scene);
        stage.show();

        this.controller = fxmlLoader.getController();
        this.controller.SetApplication(this);
        this.controller.SetStage(stage);
        this.controller.SetupView();
        this.controller.SetVersionLabel(version);
        this.controller.ShowSetup();
    }

    public void DisplayAlert(String title, String text) {
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.setTitle(title);
        alert.setHeaderText(text);
        alert.show();
    }

    public static void main(String[] args) {
        launch();
    }

    public AppSettings GetSettings() {
        return settings;
    }

    public void BuildPK3() {
        this.controller.ShowProgress();

        final Application app = this;

        new Thread(() -> {
            Runnable myRunnable = new PackageBuilder(app);
            myRunnable.run();
        }).start();
    }
}