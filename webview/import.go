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
			if err := ConditionalWrite(filepath.Join(dir, "webview.dll"), webview32.Webview); err != nil {
				return err
			}
			if err := ConditionalWrite(filepath.Join(dir, "WebView2Loader.dll"), webview32.Webview2Loader); err != nil {
				return err
			}
		} else if runtime.GOARCH == "amd64" {
			if err := ConditionalWrite(filepath.Join(dir, "webview.dll"), webview64.Webview); err != nil {
				return err
			}
			if err := ConditionalWrite(filepath.Join(dir, "WebView2Loader.dll"), webview64.Webview2Loader); err != nil {
				return err
			}
		} else {
			return fmt.Errorf("Webview Unsupported Windows Architecture.")
		}
	}
	return nil
}

func ConditionalWrite(path string, file []byte) error {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		if err := ioutil.WriteFile(path, file, 0755); err != nil {
			return err
		}
	} else {
		return nil
	}
}
