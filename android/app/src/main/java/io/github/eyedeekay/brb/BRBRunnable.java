package io.github.eyedeekay.brb;

import trayirc.BRB;
import trayirc.Trayirc;

public class BRBRunnable implements Runnable {
    BRB brb = new BRB("","","");

    @Override
    public void run() {
        brb.irc();
        brb.ircServerMain(false,false);
    }
}
