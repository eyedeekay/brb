#! /usr/bin/env sh

# NOTE: The Webview DLL's from the Golang webview repository are broken. Use the C# ones.
#wget -O WebView2Loader.dll https://github.com/webview/webview/raw/master/dll/x86/WebView2Loader.dll
#wget -O webview.dll https://github.com/webview/webview/raw/master/dll/x86/webview.dll


echo "32 bit support not available yet." | tee webview.dll | tee WebView2Loader.dll
2goarray Webview2Loader webview32 < WebView2Loader.dll > webview2loaderdll.go
2goarray Webview webview32 < webview.dll > webviewdll.go

go build
