VERSION=0.0.13
testing=rc1

USER_GH=eyedeekay
packagename=brb

GO_COMPILER_OPTS = -a -tags "netgo osusergo" -ldflags '-w'
WIN_GO_COMPILER_OPTS = -a -tags "netgo osusergo windows" -ldflags '-H=windowsgui'

export ANDROID_HOME=$(HOME)/Android/Sdk
#export ANDROID_NDK_HOME=$(HOME)/Android/Sdk/ndk/21.2.6472646

echo:
	@echo "type make version to do release $(VERSION)"

run:
	go build && ./brb

# get the date
DAILY?=$(date +%Y%m%d)
daily:
	github-release release -p -s $(GITHUB_TOKEN) -u $(USER_GH) -r $(packagename) -t v$(DAILY) -d "version $(DAILY)"

version:
	github-release release -p -s $(GITHUB_TOKEN) -u $(USER_GH) -r $(packagename) -t v$(VERSION) -d "version $(VERSION)"; sleep 2s

del:
	github-release delete -s $(GITHUB_TOKEN) -u $(USER_GH) -r $(packagename) -t v$(VERSION)

tar:
	tar --exclude .git \
		--exclude .go \
		--exclude bin \
		--exclude examples \
		-cJvf ../$(packagename)_$(VERSION).orig.tar.xz .

all: windows osx linux plugins droid

windows-runner: fmt
	CGO_ENABLED=0 GOOS=windows go build $(WIN_GO_COMPILER_OPTS) -o $(packagename)-windows.exe

windows: windows-runner

osx: fmt
	#GOARCH=386 GOOS=darwin go build $(GO_COMPILER_OPTS) -o $(packagename)-darwin-386
	#GOOS=darwin go build $(GO_COMPILER_OPTS) -o $(packagename)-darwin

linux: fmt
	GOOS=linux go build $(GO_COMPILER_OPTS) -o $(packagename)-linux

sumwindows=`sha256sum $(packagename)-windows.exe`
sumlinux=`sha256sum $(packagename)`
sumdroid=`sha256sum ./android/app/build/outputs/apk/release/app-release.apk`
sumdarwin=`sha256sum $(packagename)-darwin`

upload-windows:
	github-release upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumwindows)" -n "$(packagename)-windows.exe" -f "$(packagename)-windows.exe"

upload-windows-daily:
	github-release upload -R -u eyedeekay -r "$(packagename)" -t v$(DAILY) -l "$(sumwindows)" -n "$(packagename)-windows.exe" -f "$(packagename)-windows.exe"

upload-darwin:
	#github-release upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumdarwin)" -n "$(packagename)-darwin" -f "$(packagename)-darwin"

upload-linux:
	github-release upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumlinux)" -n "$(packagename)" -f "$(packagename)-linux"

release-android:
	github-release release -p -s $(GITHUB_TOKEN) -u $(USER_GH) -r $(packagename) -t v$(VERSION)-$(testing) -d "version $(VERSION)"

upload-android:
	github-release upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION)-$(testing) -l "$(sumdroid)" -n "$(packagename).apk" -f "./android/app/build/outputs/apk/release/app-release.apk"

upload-plugins:
	github-release upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumbblinux)" -n "brb-linux.su3" -f "../brb-linux.su3"
	github-release upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumbbwindows)" -n "brb-windows.su3" -f "../brb-windows.su3"

download-su3s:
	GOOS=windows make download-single-su3
	GOOS=linux make download-single-su3

download-single-su3:
	wget-ds "https://github.com/$(USER_GH)/$(packagename)/releases/download/$(VERSION)/$(packagename)-$(GOOS).su3"

upload: upload-windows upload-darwin upload-linux release-android upload-android upload-plugins

release: version upload

fmt:
	gofmt -w -s *.go

droidjar: android/brb/brb.aar
	ls $(HOME)/go/src/i2pgit.org/idk/libbrb

android/brb/brb.aar:
	gomobile bind -v -o android/brb/brb.aar i2pgit.org/idk/libbrb

droid: droidjar
	cd android && \
	./gradlew build

clean:
	rm -f brb brb.exe brb.aar brb-installer.exe brb-sources.jar

index:
	@echo "<!DOCTYPE html>" > index.html
	@echo "<html>" >> index.html
	@echo "<head>" >> index.html
	@echo "  <title>BRB, IRC Client, Self-Hosted Anonymous Groupchat</title>" >> index.html
	@echo "  <link rel=\"stylesheet\" type=\"text/css\" href =\"home.css\" />" >> index.html
	@echo "</head>" >> index.html
	@echo "<body>" >> index.html
	markdown README.md | tee -a index.html
	@echo "</body>" >> index.html
	@echo "</html>" >> index.html

plugins: plugin-linux plugin-windows

jarstmp:
	mkdir -p tmp/res/lib

plugins: jarstmp plugin-linux plugin-windows

plugin-linux: clean linux
	GOOS=linux make plugin

plugin-windows: clean windows-runner
	GOOS=windows make plugin

SIGNER_DIR=$(HOME)/i2p-go-keys/

plugin:
	mkdir -p tmp; cp README.md tmp
	i2p.plugin.native -name=brb-$(GOOS) \
		-signer=hankhill19580@gmail.com \
		-signer-dir=$(SIGNER_DIR) \
		-version "$(VERSION)" \
		-author=hankhill19580@gmail.com \
		-autostart=true \
		-clientname=brb-$(GOOS) \
		-consolename="BRB IRC" \
		-consoleurl="http://127.0.0.1:7669" \
		-name="brb-$(GOOS)" \
		-delaystart="1" \
		-desc="`cat ircdesc`" \
		-exename=brb-$(GOOS) \
		-icondata=icon/icon.png \
		-updateurl="http://idk.i2p/brb/brb-$(GOOS).su3" \
		-website="http://idk.i2p/brb/" \
		-command="brb-$(GOOS) -dir \$$PLUGIN/lib -eris=true -i2psite=true" \
		-license=MIT \
		-res=tmp/

export sumbblinux=`sha256sum "../brb-linux.su3"`
export sumbbwindows=`sha256sum "../brb-windows.su3"`

