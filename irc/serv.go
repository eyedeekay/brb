package trayirc

import (
	"encoding/base64"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/mmcloughlin/professor"
	"github.com/prologic/eris/irc"
	"github.com/sethvargo/go-password/password"
	"golang.org/x/crypto/bcrypt"
)

var motd string = `
.___               .__         .__ ___.    .__           .___ __________ _________
|   |  ____ ___  __|__|  ______|__|\_ |__  |  |    ____  |   |\______   \\_   ___ \
|   | /    \\  \/ /|  | /  ___/|  | | __ \ |  |  _/ __ \ |   | |       _//    \  \/
|   ||   |  \\   / |  | \___ \ |  | | \_\ \|  |__\  ___/ |   | |    |   \\     \____
|___||___|  / \_/  |__|/____  >|__| |___  /|____/ \___  >|___| |____|_  / \______  /
          \/                \/          \/            \/              \/         \/

        ___                                                 _____ __         __ 
       / _ |  ___  ___   ___  __ __ __ _  ___  __ __ ___   / ___// /  ___ _ / /_
      / __ | / _ \/ _ \ / _ \/ // //  ' \/ _ \/ // /(_-<  / /__ / _ \/ _ '// __/
     /_/ |_|/_//_/\___//_//_/\_, //_/_/_/\___/\_,_//___/  \___//_//_/\_,_/ \__/
     ==========================================================================     

`

// GenerateEncodedPassword generated a bcrypt hashed passwords
// Taken from github.com/prologic/mkpasswd
func GenerateEncodedPassword(passwd []byte) (encoded string, err error) {
	if passwd == nil {
		err = fmt.Errorf("empty password")
		return
	}
	bcrypted, err := bcrypt.GenerateFromPassword(passwd, bcrypt.MinCost)
	if err != nil {
		return
	}
	encoded = base64.StdEncoding.EncodeToString(bcrypted)
	return
}

func OutputAutoLink(dir, configfile string) string {
	f, err := ioutil.ReadFile(filepath.Join(dir, configfile+".i2p.public.txt"))
	if err != nil {
		return ""
	}
	b321 := strings.Split(string(f), "base32: ")
	if len(b321) <= 0 {
		return ""
	}
	b322 := strings.Split(b321[1], "\n")
	if len(b321) <= 0 {
		return ""
	}
	cleaned := strings.Trim(b322[0], " ")
	return "http://localhost:7669/connect?host=" + cleaned + "?name=invisibleirc"
}

func OutputServerConfigFile(dir, configfile string) (string, error) {
  os.MkdirAll(dir, 0755)
	if _, err := os.Stat(filepath.Join(dir, configfile)); err == nil {
		return "", err
	} else if !os.IsNotExist(err) {
		return "", err
	}
	operatorpassword, err := password.Generate(14, 2, 2, false, false)
	if err != nil {
		return "", err
	}
	operator, err := GenerateEncodedPassword([]byte(operatorpassword))
	if err != nil {
		return "", err
	}
	accountpassword, err := password.Generate(14, 2, 2, false, false)
	if err != nil {
		return "", err
	}
	account, err := GenerateEncodedPassword([]byte(accountpassword))
	if err != nil {
		return "", err
	}

	var serverconfigfile string = `
  mutex: {}
  network:
    name: InvisibleIRC
  server:
    password: ""
    i2plisten:
      invisibleirc:
        i2pkeys: "` + filepath.Join(dir, "iirc") + `"
        samaddr: 127.0.0.1:7656
    #torlisten:
      #hiddenirc:
        #torkeys: ` + filepath.Join(dir, "tirc") + `
        #controlport: 0
    log: ""
    motd: ` + filepath.Join(dir, "ircd.motd") + `
    name: myinvisibleirc.i2p
    description: Hidden IRC Services
  operator:
    admin:
      password: ` + operator + `
  account:
    admin:
      password: ` + account + `
`

	err = ioutil.WriteFile(filepath.Join(dir, configfile), []byte(serverconfigfile), 0644)
	if err != nil {
		return "", err
	}
	err = ioutil.WriteFile(filepath.Join(dir, "operator-admin-passwd.txt"), []byte(operatorpassword), 0644)
	if err != nil {
		return "", err
	}
	err = ioutil.WriteFile(filepath.Join(dir, "account-admin-passwd.txt"), []byte(accountpassword), 0644)
	if err != nil {
		return "", err
	}
	err = ioutil.WriteFile(filepath.Join(dir, "ircd.motd"), []byte(motd), 0644)
	if err != nil {
		return "", err
	}
	return serverconfigfile, nil
}

func IRCServerMain(version, debug bool, dir, configfile string) {
  os.MkdirAll(dir, 0755)
	if version {
		fmt.Printf(irc.FullVersion())
		os.Exit(0)
	}

	if debug {
		go professor.Launch(":6060")
	}

	if _, err := os.Stat(filepath.Join(dir, "ircd.running")); !os.IsNotExist(err) {
		return
	}
	err := ioutil.WriteFile(filepath.Join(dir, "ircd.running"), []byte(motd), 0644)
	if err != nil {
		log.Fatal("Error outputting runfile, %s", err)
	}

	_, err = OutputServerConfigFile(dir, configfile)
	if err != nil {
		log.Fatal("Config file generation error, %s", err)
	}

	config, err := irc.LoadConfig(filepath.Join(dir, configfile))
	if err != nil {
		log.Fatal("IRC Server Config file did not load successfully:", err.Error())
	}

	irc.NewServer(config).Run()
}

func Close(dir, configfile string) {
	err := os.Remove(filepath.Join(dir, "ircd.running"))
	if err != nil {
		log.Printf("Error removing runfile, %s", err)
	}
	err = os.Remove(filepath.Join(dir, "irc.running"))
	if err != nil {
		log.Printf("Error removing runfile, %s", err)
	}
}
