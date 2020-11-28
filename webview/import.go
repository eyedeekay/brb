package webviewhelper

import (
	"fmt"
	"io/ioutil"
	"path/filepath"
	"runtime"

	"github.com/eyedeekay/brb/webview/32"
	"github.com/eyedeekay/brb/webview/64"
)

func Setup(dir string) error {
	if runtime.GOOS == "windows" {
		if runtime.GOARCH == "386" {
			if err := ioutil.WriteFile(filepath.Join(dir, "webview.dll"), webview32.Webview, 0755); err != nil {
				return err
			}
			if err := ioutil.WriteFile(filepath.Join(dir, "WebView2Loader.dll"), webview32.Webview2Loader, 0755); err != nil {
				return err
			}
		} else if runtime.GOARCH == "amd64" {
			if err := ioutil.WriteFile(filepath.Join(dir, "webview.dll"), webview64.Webview, 0755); err != nil {
				return err
			}
			if err := ioutil.WriteFile(filepath.Join(dir, "WebView2Loader.dll"), webview64.Webview2Loader, 0755); err != nil {
				return err
			}
		} else {
			return fmt.Errorf("Webview Unsupported Windows Architecture.")
		}
	}
	return nil
}
