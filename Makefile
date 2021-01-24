VERSION=0.0.07

USER_GH=eyedeekay
packagename=brb

GO_COMPILER_OPTS = -a -tags "netgo osusergo" -ldflags '-w'
WIN_GO_COMPILER_OPTS = -a -tags "netgo osusergo windows" -ldflags '-H=windowsgui'

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

all: windows osx linux

windows-runner: fmt
	CC=x86_64-w64-mingw32-gcc-win32 CGO_ENABLED=1 GOOS=windows go build $(WIN_GO_COMPILER_OPTS) -o $(packagename).exe
	2goarray BRB main < brb.exe > installer/brb.go

windows: 
  #windows-runner
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
sumdarwin=`sha256sum $(packagename)-darwin`

upload-windows:
	gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumwindows)" -n "$(packagename).exe" -f "$(packagename).exe"
	gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumwindowsi)" -n "$(packagename)-installer.exe" -f "$(packagename)-installer.exe"

upload-darwin:
	#gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumdarwin)" -n "$(packagename)-darwin" -f "$(packagename)-darwin"

upload-linux:
	gothub upload -R -u eyedeekay -r "$(packagename)" -t v$(VERSION) -l "$(sumlinux)" -n "$(packagename)" -f "$(packagename)"

upload: upload-windows upload-darwin upload-linux

release: version upload

fmt:
	gofmt -w -s main.go installer/main.go webview/import.go irc/*.go

droidjar:
	gomobile bind -o brb.aar ./irc

