package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"github.com/eyedeekay/brb/icon"
	"github.com/eyedeekay/brb/webview"
	"github.com/eyedeekay/i2p-traymenu/irc"
	"github.com/eyedeekay/toopie.html/import"
	"github.com/getlantern/systray"
	"github.com/janosgyerik/portping"
	"github.com/webview/webview"
)

var usage = `Blue Rubber Band
===========

used to bind up dispatch.

An easy to use I2P IRC client.

`

//        -block default:false

var home, _ = os.UserHomeDir()

var (
	host   = flag.String("host", "localhost", "Host of the i2pcontrol and SAM interfaces")
	dir    = flag.String("dir", filepath.Join(home, "i2p/opt/native-traymenu"), "Path to the configuration directory")
	shelp  = flag.Bool("h", false, "Show the help message")
	lhelp  = flag.Bool("help", false, "Show the help message")
	debug  = flag.Bool("d", true, "Debug mode")
	sam    = flag.String("sam", "7656", "Port of the SAMv3 interface, host must match i2pcontrol")
	client = flag.Bool("client", false, "Start the chat client")
	proxy  = flag.String("p", "127.0.0.1:4444", "I2P HTTP proxy to use when following links.")
	//	local  = flag.Bool("no-i2prc", false, "Connect to locally-hosted IRC server, not I2PRC.")
	plt   = false
	local = &plt

//	block    = flag.Bool("block", false, "Block the terminal until the router is completely shut down")
)

func main() {
	flag.Parse()
	if *shelp || *lhelp {
		fmt.Printf(usage)
		flag.PrintDefaults()
		return
	}
	if err := portping.Ping("127.0.0.1", "7669", time.Second); err == nil {
		*client = true
	}
	if *client {
	  ex, err := os.Executable()
	  if err != nil {
		  panic(err)
	  }
	  place := filepath.Dir(ex)
	  webviewhelper.Setup(place)
		os.Setenv("http_proxy", "http://"+*proxy)
		os.Setenv("https_proxy", "http://"+*proxy)
		os.Setenv("ftp_proxy", "http://"+*proxy)
		os.Setenv("all_proxy", "http://"+*proxy)
		os.Setenv("no_proxy", "localhost:7669,127.0.0.1:7669")
		os.Setenv("HTTP_PROXY", "http://"+*proxy)
		os.Setenv("HTTPS_PROXY", "http://"+*proxy)
		os.Setenv("FTP_PROXY", "http://"+*proxy)
		os.Setenv("ALL_PROXY", "http://"+*proxy)
		os.Setenv("NO_PROXY", "localhost:7669,127.0.0.1:7669")

		if *local {
			var w webview.WebView
			w = webview.New(*debug)
			defer w.Destroy()
			w.SetTitle("brb")
			w.SetSize(800, 600, webview.HintNone)
			log.Println("Reaching self-hosted IRC server", trayirc.OutputAutoLink(*dir, "iirc"))
			w.Navigate(trayirc.OutputAutoLink(*dir, "iirc"))
			w.Run()
		} else {
			var w webview.WebView
			w = webview.New(*debug)
			defer w.Destroy()
			w.SetTitle("brb")
			w.SetSize(800, 600, webview.HintNone)
			w.Navigate("http://127.0.0.1:7669/connect")
			w.Run()
		}
	} else {
		onExit := func() {
			log.Println("Exiting now.")
			defer trayirc.Close(*dir, "ircd.yml")
		}
		systray.Run(onReady, onExit)
	}
}

func onReady() {
	systray.SetTemplateIcon(icon.Icon, icon.Icon)
	systray.SetTitle("brb")
	systray.SetTooltip("Easy I2PRC application.")
	systray.AddSeparator()
	mIRC := systray.AddMenuItem("IRC Chat", "Talk to others on I2P IRC")
	mSelfIRC := systray.AddMenuItem("Local Group Chat", "Connect to private IRC server")
	mSelfIRC.Hide()
	mStatOrig := systray.AddMenuItem("I2P Router Stats", "View I2P Router Console Statistics")
	systray.AddSeparator()
	mQuitOrig := systray.AddMenuItem("Close Tray", "Close the tray app, but don't shutdown the router")
	go func() {
		<-mQuitOrig.ClickedCh
		systray.Quit()
	}()

	go func() {
		for {

			go func() {
				<-mIRC.ClickedCh
				ex, err := os.Executable()
				if err != nil {
					panic(err)
				}
				log.Println(ex, "-client")
				exec.Command(ex, "-client").Run()
			}()

			go func() {
				<-mSelfIRC.ClickedCh
				ex, err := os.Executable()
				if err != nil {
					panic(err)
				}
				exec.Command(ex, "-client", "-no-i2prc").Run()
			}()

			go func() {
				<-mStatOrig.ClickedCh
				log.Println("Launching toopie.html")
				go toopiexec.Run()
			}()

			time.Sleep(time.Second)
		}
	}()

	trayirc.IRC(*dir)
}
