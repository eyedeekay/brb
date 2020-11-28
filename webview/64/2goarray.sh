#! /usr/bin/env sh

# NOTE: The Webview DLL's from the Golang webview repository are broken. Use the C# ones.
#wget -O WebView2Loader.dll https://github.com/webview/webview/raw/master/dll/x64/WebView2Loader.dll
#wget -O webview.dll https://github.com/webview/webview/raw/master/dll/x64/webview.dll


wget -O WebView2Loader.dll https://github.com/webview/webview_csharp/raw/master/libs/WebView2Loader.dll
wget -O webview.dll https://github.com/webview/webview_csharp/raw/master/libs/webview.dll

2goarray Webview2Loader webview64 < WebView2Loader.dll > webview2loaderdll.go
2goarray Webview webview64 < webview.dll > webviewdll.go

go build
