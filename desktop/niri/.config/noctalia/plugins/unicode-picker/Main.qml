import QtQuick
import Quickshell.Io
import qs.Services.UI

Item {
  property var pluginApi: null

  IpcHandler {
    target: "plugin:unicode"
    function toggle() {
      pluginApi.withCurrentScreen(screen => {
        var launcherPanel = PanelService.getPanel("launcherPanel", screen);
        if (!launcherPanel)
          return;
        var searchText = launcherPanel.searchText || "";
        var isInUnicodeMode = searchText.startsWith(">unicode");
        if (!launcherPanel.isPanelOpen) {
          launcherPanel.open();
          launcherPanel.setSearchText(">unicode ");
        } else if (isInUnicodeMode) {
          launcherPanel.close();
        } else {
          launcherPanel.setSearchText(">unicode ");
        }
      });
    }
  }
}
