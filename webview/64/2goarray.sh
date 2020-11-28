#! /usr/bin/env sh

wget -O WebView2Loader.dll https://github.com/webview/webview/raw/master/dll/x64/WebView2Loader.dll
wget -O webview.dll https://github.com/webview/webview/raw/master/dll/x64/webview.dll

2goarray Webview2Loader webview64 < WebView2Loader.dll > webview2loaderdll.go
2goarray Webview webview64 < webview.dll > webviewdll.go

go build
