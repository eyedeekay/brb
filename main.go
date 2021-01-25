package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"runtime"
	"time"

	"github.com/eyedeekay/brb/icon"
	"github.com/eyedeekay/brb/irc"
	"github.com/eyedeekay/goSam"
	"github.com/eyedeekay/toopie.html/lib"
	"github.com/getlantern/go-socks5"
	"github.com/getlantern/systray"
	"github.com/janosgyerik/portping"
	"github.com/webview/webview"
	"github.com/zserge/lorca"
)

var usage = `Blue Rubber Band
===========

used to bind up dispatch.

An easy to use I2P IRC client.

`

//        -block default:false

var home, _ = os.UserHomeDir()

var (
	host         = flag.String("host", "localhost", "Host of the i2pcontrol and SAM interfaces")
	dir          = flag.String("dir", filepath.Join(home, "i2p/opt/native-traymenu"), "Path to the configuration directory")
	shelp        = flag.Bool("h", false, "Show the help message")
	lhelp        = flag.Bool("help", false, "Show the help message")
	debug        = flag.Bool("d", false, "Debug mode")
	sam          = flag.String("sam", "7656", "Port of the SAMv3 interface, host must match i2pcontrol")
	client       = flag.Bool("client", false, "Start the chat client")
	proxy        = flag.String("p", "127.0.0.1:4444", "I2P HTTP proxy to use when following links.")
	forcewebview = flag.Bool("webview", false, "(Windows-Only)Force the use of a WebView window instead of a Lorca window")
	monitor      = flag.Bool("toopie", false, "Launch toopie.html to monitor I2P router health.")
	ircserver    = flag.Bool("eris", true, "Launch embedded Eris IRC Server instance on an I2P service.")
	//	local  = flag.Bool("no-i2prc", false, "Connect to locally-hosted IRC server, not I2PRC.")
	plt   = false
	local = &plt
	ln    net.Listener

//	block    = flag.Bool("block", false, "Block the terminal until the router is completely shut down")
)

var (
	socksaddr = flag.String("socks", "", "Start an embedded I2P SOCKS Proxy on a local port")
)

func Socks() {
	samsocks, err := goSam.NewClient("127.0.0.1:" + *sam)
	if err != nil {
		panic(err)
	}
	log.Println("Client Created")

	// create a transport that uses SAM to dial TCP Connections
	conf := &socks5.Config{
		Dial:     samsocks.DialContext,
		Resolver: samsocks,
	}
	server, err := socks5.New(conf)
	if err != nil {
		panic(err)
	}

	// Create SOCKS5 proxy on localhost port 8000
	if err := server.ListenAndServe("tcp", "127.0.0.1:"+*socksaddr); err != nil {
		panic(err)
	}
}

func main() {
	flag.Parse()
	if *shelp || *lhelp {
		fmt.Printf(usage)
		flag.PrintDefaults()
		return
	}
	if *socksaddr != "" {
		if err := portping.Ping("127.0.0.1", *socksaddr, time.Second); err != nil {
			go Socks()
		}
	}
	if err := portping.Ping("127.0.0.1", "7669", time.Second); err == nil {
		*client = true
	}
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	go func() {
		for sig := range c {
			log.Println(sig)
			trayirc.Close(*dir, "ircd.yml")
			os.Exit(0)
		}
	}()
	if *client {
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
			if runtime.GOOS != "windows" {
				var w webview.WebView
				w = webview.New(*debug)
				defer w.Destroy()
				w.SetTitle("brb")
				w.SetSize(800, 600, webview.HintNone)
				log.Println("Reaching self-hosted IRC server", trayirc.OutputAutoLink(*dir, "iirc"))
				w.Navigate(trayirc.OutputAutoLink(*dir, "iirc"))
				w.Run()
			} else if *forcewebview {
				var w webview.WebView
				w = webview.New(*debug)
				defer w.Destroy()
				w.SetTitle("brb")
				w.SetSize(800, 600, webview.HintNone)
				w.Navigate(trayirc.OutputAutoLink(*dir, "iirc"))
				w.Run()
			} else {
				ui, err := lorca.New(trayirc.OutputAutoLink(*dir, "iirc"), "", 480, 320)
				if err != nil {
					log.Fatal(err)
				}
				defer ui.Close()
				// Wait until UI window is closed
				<-ui.Done()
			}
		} else {
			if runtime.GOOS != "windows" {
				var w webview.WebView
				w = webview.New(*debug)
				defer w.Destroy()
				w.SetTitle("brb")
				w.SetSize(800, 600, webview.HintNone)
				w.Navigate("http://127.0.0.1:7669/connect")
				w.Run()
			} else if *forcewebview {
				var w webview.WebView
				w = webview.New(*debug)
				defer w.Destroy()
				w.SetTitle("brb")
				w.SetSize(800, 600, webview.HintNone)
				w.Navigate("http://127.0.0.1:7669/connect")
				w.Run()
			} else {
				ui, err := lorca.New("http://127.0.0.1:7669/connect", "", 800, 600)
				if err != nil {
					log.Fatal(err)
				}
				defer ui.Close()
				// Wait until UI window is closed
				<-ui.Done()
			}
		}

	} else if *monitor {
		if runtime.GOOS != "windows" {
			var w webview.WebView
			w = webview.New(*debug)
			defer w.Destroy()
			w.SetTitle("brb")
			w.SetSize(800, 600, webview.HintNone)
			w.Navigate(fmt.Sprintf("http://%s", "127.0.0.1:7667"))
			w.Run()
		} else {
			ui, err := lorca.New(fmt.Sprintf("http://%s", "127.0.0.1:7667"), "", 800, 600)
			if err != nil {
				log.Fatal(err)
			}
			defer ui.Close()
			// Wait until UI window is closed
			<-ui.Done()
		}
	} else {
		if *monitor {
			if err := portping.Ping("127.0.0.1", "7667", time.Second); err != nil {
				if err := portping.Ping("127.0.0.1", "7670", time.Second); err != nil {
					ln = toopie.Listen("7667", 7670)
				}
			}
		}

		onExit := func() {
			log.Println("Exiting now.")
			defer trayirc.Close(*dir, "ircd.yml")
		}
		if *ircserver {
			if err := portping.Ping("127.0.0.1", "6667", time.Second); err != nil {
				go trayirc.IRCServerMain(false, *debug, *dir, "ircd.yml")
				time.Sleep(time.Duration(time.Second * 5))
			}
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
	ircurl := trayirc.OutputAutoLink(*dir, "iirc")
	log.Println("Checking whether to un-hide embedded IRC server from menu", ircurl)
	if ircurl != "" {
		if *ircserver == true {
			mSelfIRC.Show()
		}
	}
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
				ex, err := os.Executable()
				if err != nil {
					panic(err)
				}
				exec.Command(ex, "-toopie").Run()
			}()

			time.Sleep(time.Second)
		}
	}()
	trayirc.IRC(*dir)
}
