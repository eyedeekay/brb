brb
===

Blue Rubber Band is mostly nothing except an application which
*automatically* configures an Internet Relay Chat client for use
with the I2P network. The actual IRC client is *[khlieng/dispatch](https://github.com/khlieng/dispatch)*
and they deserve most of the credit! All I did was add I2P support to
their application, then wrap it up in the interface I happen to think
was the most logical. This adds a few very simple things to Dispatch
to make it suitable for use as a user-friendly I2P IRC client.

BRB also wraps up an IRC server, based on the one found in *[prologic/eris](https://git.mills.io/prologic/eris).*
This makes it useful as a sort of ad-hoc anonymous groupchat system. Again,
many thanks to prologic and the other people who have worked on Eris. Eris
will be configured to listen on an I2P "SAM" connection, just like Dispatch,
so all the configuration is automatic.

Lastly, using [eyedeekay/sam-forwarder](https://github.com/eyedeekay/sam-forwarder),
the WebIRC interface provided by *Dispatch*. In this way the Dispatch WebUI, which
is capable of supporting multiple users at the same time, becomes available as an
I2P Site. Other I2P users can access the WebUI and use it as a WebIRC client to any
in-I2P IRC network.

In addition to that, it sets up:

 1. **A taskbar icon:** using the [getlantern/systray](https://github.com/getlantern/systray)
  library and an accompanying menu, which can be used to launch the IRC client interface.
 2. **A menu** clicking the taskbar icon will open the menu, which presents
  options for launching the webview, connecting the webview to either I2PRC
  or your own private IRC server provided by the local Eris instance, and
  a panel to check the health of your I2P router.
 3. **A Webview:** using the [webview/webview](https://github.com/webview/webview)
  library. It's configured to proxy all traffic to I2P via the default
  HTTP proxy, *except* for traffic which is destined for the dispatch
  IRC client. This makes it capable of browsing I2P sites. It is
  **not reccommended** that you use this feature for general I2P browsing,
  but it should be ok for opening links from parties **who you trust** to
  give you the link. **On Windows** the webUI is provided by
  [zserge/lorca](https://github.com/zserge/lorca) due to bugs Webview on
  Windows. This requires Chrome or Chromium to be installed. If it is not
  installed, lorca will prompt you to install it. Lorca configures Chromium
  to minimize Google telemetry, and requests away from the Dispatch client
  will still be proxied to the I2P network. This is also **not recommended**
  for use as a general I2P browser. <<
 4. **An I2P Diagnostic View:** using the [I2PControl API](https://geti2p.net/en/docs/api/i2pcontrol)
  we connect to I2P to gather information about it's readiness in another
  webview.

The result is a Modern-looking, no fuss Irc2P Client.

Android Support
---------------

brb is also available experimentally for Android. In this case, the webview
parts are provided by the corresponding Android APIs. The final goal of the
Android application is to implement all the same features as the Desktop
application, including the Eris server. In this case, instead of a 
**taskbar icon** and a **menu** BRB provides:

 1. **A Foreground Service:** The Go parts of BRB are adapted to be "runnable"
  and controlled by a Foreground Service. This makes BRB "Work" on Android,
  but it doesn't have a menu to expose any of it's features.
 2. **A NotificationArea with a tray menu:** To set up the means to launch into
  various parts of the BRB app, a NotificationArea is added(persistently) into
  the toolbar at the top of your Android device's UI. It has the same buttons as
  the Menu on the desktop.

Enable the SAM API!
-------------------

brb uses the SAM API to set up it's connection to IRC networks inside of I2P.
This means that it can support as many IRC networks as you want to connect to.
With i2pd, the SAM API is already enabled. With Java I2P, you must enable it
on the [Config Clients](http://localhost:7657/configclients) page.



  >> `If you do not want to use either the WebView or Chromium to wrap the
  user-interface, you can instead use any web browser and direct it to
  localhost:7669. There is a container tab for this in
  [I2P in Private Browsing](https://github.com/eyedeekay/I2P-in-Private-Browsing-Mode-Firefox).
  This should be a reasonable baseline for non-sensitive I2P browsing.`
