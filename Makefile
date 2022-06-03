VERSION=0.0.12
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
DAILY=$(date +%Y%m%d)
daily:
	gothub release -p -s $(GITHUB_TOKEN) -u $(USER_GH) -r $(packagename) -t v$(DAILY) -d "version $(DAILY)"

version:
	gothub release -p -s $(GITHUB_TOKEN) -u $(USER_GH) -r $(packagename) -t v$(VERSION) -d "version $(VERSION)"

del:
	gothub delete -s $(GITHUB_TOKEN) -u $(USER_GH) -r $(packagename) -t v$(VERSION)

tar:
	tar --exclude .git \
		--exclude .go \
		--exclude bin \
		--exclude examples \
		-cJvf ../$(packagename)_$(VERSION).orig.tar.xz .

all: windows osx linux plugins droid

windows-runner: fmt
	CC=x86_64-w64-mingw32-gcc-win32 CGO_ENABLED=0 GOOS=windows go build $(WIN_GO_COMPILER_OPTS) -o $(packagename)-windows.exe

windows: windows-runner

osx: fmt
	#GOARCH=386 GOOS=darwin go build $(GO_COMPILER_OPTS) -o $(packagename)-darwin-386
	#GOOS=darwin go build $(GO_COMPILER_OPTS) -o $(packagename)-darwin

linux: fmt
	GOOS=linux go build $(GO_COMPILER_OPTS) -o $(packagename)

sumwindows=`sha256sum $(packagename).exe`
sumlinux=`sha256sum $(packagename)`
sumdroid=`sha256sum ./android/app/build/outputs/apk/release/app-release.apk`
sumdarwin=`sha256sum $(packagename)-darwin`

upload-windows:
	gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumwindows)" -n "$(packagename).exe" -f "$(packagename).exe"

upload-windows-daily:
	gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(DAILY) -l "$(sumwindows)" -n "$(packagename).exe" -f "$(packagename).exe"

upload-darwin:
	#gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumdarwin)" -n "$(packagename)-darwin" -f "$(packagename)-darwin"

upload-linux:
	gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumlinux)" -n "$(packagename)" -f "$(packagename)"

release-android:
	gothub release -p -s $(GITHUB_TOKEN) -u $(USER_GH) -r $(packagename) -t v$(VERSION)-$(testing) -d "version $(VERSION)"

upload-android:
	gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION)-$(testing) -l "$(sumdroid)" -n "$(packagename).apk" -f "./android/app/build/outputs/apk/release/app-release.apk"

upload-plugins:
	gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumbblinux)" -n "brb-linux.su3" -f "../brb-linux.su3"
	gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumbbwindows)" -n "brb-windows.su3" -f "../brb-windows.su3"

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

plugin:
	i2p.plugin.native -name=brb-$(GOOS)
		-signer=hankhill19580@gmail.com \
		-version "$(VERSION)" \
		-author=hankhill19580@gmail.com \
		-autostart=true \
		-clientname=brb-$(GOOS)
		-consolename="BRB Chat" \
		-consoleurl="http://127.0.0.1:7669" \
		-command="brb -dir \$$PLUGIN/lib -eris=true -i2psite=true" \
		-consolename="BRB IRC" \
		-delaystart="3" \
		-icondata=icon/icon.png \
		-desc="`cat ircdesc`" \
		-exename=brb-$(GOOS)
		-license=MIT \
		-res="tmp/res/"
	cp -v ../brb-$(GOOS).su3 .
	unzip -o brb-$(GOOS).zip -d brb-$(GOOS)-zip

export sumbblinux=`sha256sum "../brb-linux.su3"`
export sumbbwindows=`sha256sum "../brb-windows.su3"`