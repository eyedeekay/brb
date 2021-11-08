VERSION=0.0.10
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

all: windows osx linux droid

windows-runner: fmt
	CC=x86_64-w64-mingw32-gcc-win32 CGO_ENABLED=1 GOOS=windows go build $(WIN_GO_COMPILER_OPTS) -o $(packagename).exe
	2goarray BRB main < brb.exe > installer/brb.go

windows: windows-runner
	CC=x86_64-w64-mingw32-gcc-win32 CGO_ENABLED=1 GOOS=windows go build $(WIN_GO_COMPILER_OPTS) -o $(packagename)-installer.exe ./installer
	#CC=i686-w64-mingw32-gcc-win32 CGO_ENABLED=1 GOOS=windows GOARCG=i386 go build $(WIN_GO_COMPILER_OPTS) -o $(packagename)-32.exe

osx: fmt
	#GOARCH=386 GOOS=darwin go build $(GO_COMPILER_OPTS) -o $(packagename)-darwin-386
	#GOOS=darwin go build $(GO_COMPILER_OPTS) -o $(packagename)-darwin

linux: fmt
	GOOS=linux go build $(GO_COMPILER_OPTS) -o $(packagename)

sumwindows=`sha256sum $(packagename).exe`
sumwindowsi=`sha256sum $(packagename)-installer.exe`
sumlinux=`sha256sum $(packagename)`
sumdroid=`sha256sum ./android/app/build/outputs/apk/release/app-release.apk`
sumdarwin=`sha256sum $(packagename)-darwin`

upload-windows:
	gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumwindows)" -n "$(packagename).exe" -f "$(packagename).exe"
	gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumwindowsi)" -n "$(packagename)-installer.exe" -f "$(packagename)-installer.exe"

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

upload: upload-windows upload-darwin upload-linux release-android upload-android upload-pluginss

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

plugin-linux: clean linux
	i2p.plugin.native -name=brb \
		-signer=hankhill19580@gmail.com \
		-version "$(VERSION)" \
		-author=hankhill19580@gmail.com \
		-autostart=true \
		-clientname=brb \
		-consolename="BRB Chat" \
		-consoleurl="http://127.0.0.1:7669" \
		-command="brb -dir=\$$PLUGIN/lib -eris=true -i2psite=true" \
		-consolename="BRB IRC" \
		-delaystart="200" \
		-icondata=icon/icon.png \
		-desc="`cat ircdesc`" \
		-exename=brb \
		-license=MIT
	cp -v brb.su3 ../brb-linux.su3
	cp -v ../brb-linux.su3 .
	unzip -o brb.zip -d brb-zip

plugin-windows: clean windows
	i2p.plugin.native -name=brb \
		-signer=hankhill19580@gmail.com \
		-version "$(VERSION)" \
		-author=hankhill19580@gmail.com \
		-autostart=true \
		-clientname=brb.exe \
		-consolename="BRB Chat" \
		-consoleurl="http://127.0.0.1:7669" \
		-command="brb.exe -dir=\$$PLUGIN/lib -eris=true -i2psite=true" \
		-consolename="BRB IRC" \
		-delaystart="200" \
		-desc="`cat ircdesc`" \
		-icondata=icon/icon.png \
		-exename=brb.exe \
		-license=MIT \
		-targetos="windows" \
		-res=windll
	cp -v brb.su3 ../brb-windows.su3
	cp -v ../brb-windows.su3 .
	unzip -o brb.zip -d brb-zip-win

export sumbblinux=`sha256sum "../brb-linux.su3"`
export sumbbwindows=`sha256sum "../brb-windows.su3"`