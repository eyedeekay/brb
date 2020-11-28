#! /usr/bin/env sh

wget -O WebView2Loader.dll https://github.com/webview/webview/raw/master/dll/x86/WebView2Loader.dll
wget -O webview.dll https://github.com/webview/webview/raw/master/dll/x86/webview.dll

2goarray Webview2Loader webview32 < WebView2Loader.dll > webview2loaderdll.go
2goarray Webview webview32 < webview.dll > webviewdll.go

go build
