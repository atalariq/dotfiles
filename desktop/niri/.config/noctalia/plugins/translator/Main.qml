import QtQuick
import Quickshell.Io
import qs.Services.UI
import "translatorUtils.js" as TranslatorUtils

Item {
  property var pluginApi: null

  IpcHandler {
    target: "plugin:translator"
    function toggle(language: string, text: string) {
      if (!pluginApi) return;
      
      pluginApi.withCurrentScreen(screen => {
        var launcherPanel = PanelService.getPanel("launcherPanel", screen);
        if (!launcherPanel)
          return;
        
        var searchText = launcherPanel.searchText || "";
        var isInTranslateMode = searchText.startsWith(">translate");
        
        var newSearchText = ">translate ";
        if (language && language.trim() !== "") {
          var langCode = TranslatorUtils.getLanguageCode(language);
          if (langCode) {
            newSearchText += langCode + " ";
          }
        }
        
        if (text) {
            newSearchText += text;
        }
        
        if (!launcherPanel.isPanelOpen) {
          launcherPanel.open();
          launcherPanel.setSearchText(newSearchText);
        } else if (isInTranslateMode) {
          launcherPanel.close();
        } else {
          launcherPanel.setSearchText(newSearchText);
        }
      });
    }
  }
}
