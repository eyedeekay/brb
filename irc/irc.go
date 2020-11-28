package trayirc

import (
	"io/ioutil"
	"log"
	"os"
	"path/filepath"

	"github.com/khlieng/dispatch/config"
	"github.com/khlieng/dispatch/server"
	"github.com/khlieng/dispatch/storage"
	"github.com/khlieng/dispatch/storage/bleve"
	"github.com/khlieng/dispatch/storage/boltdb"
)

var configfile = `# IP address to listen on, leave empty to listen on anything
address = "localhost"
port = 7669
# Run ident daemon on port 113
identd = false
# Hex encode the users IP and use it as the ident
hexIP = false
# Automatically reply to common CTCP messages
auto_ctcp = true
# Verify the certificate chain presented by the IRC server, if this check fails
# the user will be able to choose to still connect
verify_certificates = true

# Defaults for the client connect form
[defaults]
name = "i2prc"
host = "irc.echelon.i2p"
port = 6697
channels = [
  "#i2p",
  "#i2p-dev",
  "#i2p-android-dev"
]
server_password = ""
ssl = false
# Only allow a nick to be filled in
readonly = false
# Show server and channel info when readonly is enabled
show_details = false

[https]
enabled = false
port = 443
# Path to your cert and private key if you are not using
# the Let's Encrypt integration
cert = ""
key = ""

[letsencrypt]
# Your domain or subdomain, if not set a certificate will be
# fetched for whatever domain dispatch gets accessed through
domain = ""
# An email address lets you recover your accounts private key
email = ""

# Not implemented
[auth]
# Allow usage without being logged in, all channels and settings get
# transferred when logging in or registering
anonymous = true
# Enable username/password login
login = true
# Enable username/password registration
registration = true

[auth.providers.github]
key = ""
secret = ""

[auth.providers.facebook]
key = ""
secret = ""

[auth.providers.google]
key = ""
secret = ""

[auth.providers.twitter]
key = ""
secret = ""

[dcc]
# Receive files through DCC, the user gets to choose if they want to accept the file,
# the file download then gets proxied to the user
enabled = true

[dcc.autoget]
# Instead of proxying the file download directly to the user, dispatch automatically downloads
# DCC files and sends a download link to the user once its done
enabled = false
# Delete the file after the user has downloaded it once
delete = true
# Delete the file after a certain time period of inactivity, not implemented yet
delete_after = "30m"

[proxy]
# Dispatch will make all outgoing connections through the specified proxy when enabled
enabled = true
protocol = "i2p"
host = "127.0.0.1"
port = 7656
#username = ""
#password = ""

# HTTP Strict-Transport-Security
[https.hsts]
enabled = false
max_age = 31536000
include_subdomains = false
preload = false

# Add your own HTTP headers to the index page
[headers]
# X-Example = "Rainbows"
`

func initConfig(configPath string, overwrite bool) error {
	if _, err := os.Stat(configPath); overwrite || os.IsNotExist(err) {
		log.Println("Writing default config to", configPath)
		err := ioutil.WriteFile(configPath, []byte(configfile), 0600)
		if err != nil {
			return err
		}
	}
	return nil
}

func IRC(confdir string) {
  os.MkdirAll(confdir, 0755)
	if _, err := os.Stat(filepath.Join(confdir, "irc.running")); !os.IsNotExist(err) {
		return
	}
	err := ioutil.WriteFile(filepath.Join(confdir, "irc.running"), []byte(motd), 0644)
	if err != nil {
		log.Fatal("Error outputting runfile, %s", err)
	}

	storage.Initialize(confdir, confdir, confdir)

	err = initConfig(storage.Path.Config(), false)
	if err != nil {
		log.Fatal(err)
	}

	log.Println("Storing data at", storage.Path.DataRoot())

	db, err := boltdb.New(storage.Path.Database())
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	storage.GetMessageStore = func(user *storage.User) (storage.MessageStore, error) {
		return boltdb.New(storage.Path.Log(user.Username))
	}

	storage.GetMessageSearchProvider = func(user *storage.User) (storage.MessageSearchProvider, error) {
		return bleve.New(storage.Path.Index(user.Username))
	}

	cfg, cfgUpdated := config.LoadConfig()
	dispatch := server.New(cfg)

	go func() {
		for {
			dispatch.SetConfig(<-cfgUpdated)
			log.Println("New config loaded")
		}
	}()

	dispatch.Store = db
	dispatch.SessionStore = db

	dispatch.Run()
}
