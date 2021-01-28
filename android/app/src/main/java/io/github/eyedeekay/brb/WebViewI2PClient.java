package io.github.eyedeekay.brb;

import android.webkit.WebView;
import android.webkit.WebViewClient;

public class WebViewI2PClient  extends WebViewClient {
    @Override
    public boolean shouldOverrideUrlLoading(WebView webView, String url) {
        return false;
    }
}
