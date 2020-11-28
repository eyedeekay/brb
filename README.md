brb
===

Blue Rubber Band is mostly nothing except an application which
*automatically* configures an Internet Relay Chat client for use
with the I2P network. The actual IRC client is [khlieng/dispatch](https://github.com/khlieng/dispatch)
and they deserve most of the credit! All I did was add I2P support to
their application, then wrap it up in the interface I happen to think
was the most logical. This adds a few very simple things to Dispatch
to make it suitable for use as a user-friendly I2P IRC client.

 1. **A taskbar icon:** using the [getlantern/systray](https://github.com/getlantern/systray)
  library and an accompanying menu, which can be
 2. **A Webview:** using the [webview/webview](https://github.com/webview/webview)
  library. It's configured to proxy all traffic to I2P via the default
  HTTP proxy, *except* for traffic which is destined for the dispatch
  IRC client. This makes it capable of browsing I2P sites. It is
  **not reccommended** that you use this feature for general I2P browsing,
  but it should be ok for opening links from parties **who you trust** to
  give you the link.
 3. **An I2P Diagnostic View:** using the [I2PControl API](https://geti2p.net/en/docs/api/i2pcontrol)
  we connect to I2P to gather information about it's readiness in another
  webview.

The result is a Modern-looking, no fuss Irc2P Client.

Enable the SAM API!
-------------------

brb uses the SAM API to set up it's connection to IRC networks inside of I2P.
This means that it can support as many IRC networks as you want to connect to.
With a

