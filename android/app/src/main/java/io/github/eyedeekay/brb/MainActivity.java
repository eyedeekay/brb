package io.github.eyedeekay.brb;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebView;

import androidx.appcompat.app.AppCompatActivity;

import java.net.Proxy;
import java.net.ProxySelector;
import java.net.URI;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import trayirc.BRB;
import trayirc.Trayirc;



//import androidx. //webkit.ProxyConfig;

public class MainActivity extends AppCompatActivity {
    //WebView webView;
    static final ExecutorService service = Executors.newCachedThreadPool();

    WebViewI2PClient webViewI2PClient;
    BRBRunnable trayirc = new BRBRunnable();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setProxy();
        setContentView(R.layout.activity_main);

        WebView webView = findViewById(R.id.webView);

        Launch(trayirc);

        webView.getSettings().setJavaScriptEnabled(true);

        webView.getSettings().setDatabaseEnabled(true);
        webView.getSettings().setDomStorageEnabled(true);
        String databasePath = webView.getContext().getDir("databases", Context.MODE_PRIVATE).getPath();
        webView.getSettings().setDatabasePath(databasePath);
        webView.getSettings().setBuiltInZoomControls(true);
        webView.setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
        webView.setScrollbarFadingEnabled(false);
        webView.setVerticalScrollBarEnabled(true);
        webView.setHorizontalScrollBarEnabled(true);
        //webView.setWebViewClient(webViewI2PClient);
        webView.loadUrl("http://127.0.0.1:7669");
    }
    @Override
    protected void onResume(){
        super.onResume();
        setProxy();
        WebView webView = findViewById(R.id.webView);
        webView.loadUrl("http://127.0.0.1:7669");
    }
    static void Launch(BRBRunnable r) {
        Log.d("Runnable","Launching BRB");
        service.submit(r);
        Log.d("Runnable","Launched BRB");
    }
    private void setProxy() {
        try {
            String proxyHost = "127.0.0.1";
            String proxyPort = "4444";
            System.setProperty("http.proxyHost", proxyHost);
            System.setProperty("http.proxyPort", proxyPort);
            System.setProperty("https.proxyHost", proxyHost);
            System.setProperty("https.proxyPort", proxyPort);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
