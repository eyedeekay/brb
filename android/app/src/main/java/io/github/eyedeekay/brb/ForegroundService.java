package io.github.eyedeekay.brb;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.IBinder;
//import android.support.annotation.Nullable;
//import android.support.v4.app.NotificationCompat;

import androidx.core.app.NotificationCompat;

import org.jetbrains.annotations.Nullable;

import static android.app.Notification.EXTRA_NOTIFICATION_ID;

public class ForegroundService extends Service {
    public static final String CHANNEL_ID = "BRBForegroundServiceChannel";
    IntentFilter filter = new IntentFilter();
    BRBReciever myReceiver = new BRBReciever();
    String ERIS_COPY = "io.github.eyedeekay.brb.ERIS_COPY";



    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    public PendingIntent CopyB32Intent() {
        Intent snoozeIntent = new Intent(this, BRBReciever.class);
        snoozeIntent.setAction(ERIS_COPY);
        snoozeIntent.putExtra(EXTRA_NOTIFICATION_ID, 0);
        PendingIntent snoozePendingIntent =
                PendingIntent.getBroadcast(this, 0, snoozeIntent, 0);
        return snoozePendingIntent;
    }

    public PendingIntent ReturnIntent(Intent intent, String input){
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, 0);
        return pendingIntent;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        createNotificationChannel();

        filter.addAction(ERIS_COPY);
        registerReceiver(myReceiver, filter);

        String inputHome = intent.getStringExtra("inputHome");
        PendingIntent pendingIntent = ReturnIntent(intent, inputHome);

        String inputCopy = intent.getStringExtra("inputCopy");
        PendingIntent pendingCopyB32Intent = ReturnIntent(intent, inputCopy);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID);
        builder.setContentTitle(getString(R.string.ForegroundServiceName));
        builder.setContentText(inputHome);
        builder.setSmallIcon(R.drawable.ic_launcher_foreground);
        builder.setContentIntent(pendingIntent);
        builder.addAction(R.drawable.ic_launcher_background, "Copy IRC Server Address for Sharing",
                pendingCopyB32Intent);

        Notification notification = builder
                .build();
        startForeground(1, notification);
        return START_NOT_STICKY;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "BRB IRC Service",
                    NotificationManager.IMPORTANCE_DEFAULT
            );

            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
        }
    }

}
