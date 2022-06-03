module github.com/eyedeekay/brb

go 1.15

require (
	fyne.io/systray v1.9.1-0.20220524173754-865158adf791
	github.com/atotto/clipboard v0.1.4
	github.com/eyedeekay/goSam v0.32.54-0.20220603035649-cfdb60d9327b
	github.com/eyedeekay/toopie.html v0.0.0-20201129001559-54654990ffb9
	github.com/getlantern/go-socks5 v0.0.0-20171114193258-79d4dd3e2db5
	github.com/janosgyerik/portping v1.0.1
	github.com/webview/webview v0.0.0-20220603044542-dc41cdcc2961
	github.com/zserge/lorca v0.1.10
	i2pgit.org/idk/libbrb v0.0.0-20220603222150-84751ed17615
)

//replace github.com/prologic/eris => github.com/prologic/eris v1.6.7-0.20210430033226-64d4acc46ca7
//replace github.com/prologic/eris => git.mills.io/prologic/eris v1.6.7-0.20210430033226-64d4acc46ca7

replace github.com/willf/bitset => github.com/bits-and-blooms/bitset v1.1.10

replace github.com/caddyserver/certmagic => github.com/caddyserver/certmagic v0.11.2
