package main

import (
	"os"
	"os/exec"
	"path/filepath"

	"github.com/eyedeekay/brb/webview"
)

func main() {
	ex, err := os.Executable()
	if err != nil {
		panic(err)
	}
	place := filepath.Dir(ex)
	webviewhelper.Setup(place)
	if err = webviewhelper.ConditionalWrite(filepath.Join(place, "brb.exe"), BRB); err != nil {
		panic(err)
	}
	exec.Command(filepath.Join(place, "brb.exe"), "-client").Run()
}
