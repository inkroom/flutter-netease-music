package tech.soit.quiet.app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.media.AudioManager;
import android.media.MediaMetadata;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;
import android.util.Log;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.media.app.NotificationCompat.MediaStyle;

import org.jetbrains.annotations.Nullable;

import java.util.Calendar;
import android.widget.RemoteViews;
import android.view.View;
public class MusicPlayerService extends Service implements AudioManager.OnAudioFocusChangeListener {

    @Override
    public void onAudioFocusChange(int focusChange) {

    }

    class LocalBinder extends Binder {
        MusicPlayerService service = MusicPlayerService.this;
    }

    private NotificationManagerCompat manager;

    private final int notifyId = 13372589;
    private final String channelId = "musicplayer";
    private final LocalBinder binder = new LocalBinder();
    private long timeDiff = 0;
    private long timePaused = 0;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.v("MusicPlayerService", "onStartCommand");
        manager = NotificationManagerCompat.from(getApplicationContext());

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            String channelName = "Music Player";
            NotificationChannel channel = new NotificationChannel(
                    channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT);
            channel.setSound(null, null);
            channel.enableLights(true);
            channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
            manager.createNotificationChannel(channel);
        }

        // Fixing: Context.startForegroundService() did not then call Service.startForeground()
        // Start an empty notification before showing the real one
        showEmptyNotification();
        return START_NOT_STICKY;
    }

    private void showEmptyNotification() {
        MediaSessionCompat session = new MediaSessionCompat(getApplicationContext(), "MusicPlayerService");
        MediaStyle mediaStyle = new MediaStyle().setMediaSession(session.getSessionToken());
        NotificationCompat.Builder builder = new NotificationCompat
                .Builder(getApplicationContext(), channelId)
                .setContentTitle("")
                .setContentText("")
                .setSmallIcon(R.drawable.notification_icon)
                .setStyle(mediaStyle);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder.setChannelId(channelId);
        }

        startForeground(notifyId, builder.build());
    }

    private PendingIntent pendingIntent(int code, Intent intent) {
        return PendingIntent.getBroadcast(
                getApplicationContext(), code, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    }

    private NotificationCompat.Action mediaAction(int icon, int code, String title, Intent intent) {
        PendingIntent pendingIntent = pendingIntent(code, intent);
        return new NotificationCompat.Action.Builder(icon, title, pendingIntent).build();
    }

    /*private NotificationCompat.Action mediaAction(int icon, String title, long action) {
        PendingIntent pendingIntent = MediaButtonReceiver.buildMediaButtonPendingIntent(
            this, action);
        return new NotificationCompat.Action.Builder(icon, title, pendingIntent).build();
    }*/

    void showNotification(Music music) {
        MediaSessionCompat session = music.session;

        if (session == null) {
            return;
        }

        // when music is not playing, detached notification from its service
        // so the notification will become cancellable
        if (!music.isPlaying) {
            detachNotifyFromService();
        }

        //Log.v("MusicPlayerService", "Updating Notification...");
        //Log.v("MusicPlayerService", "Position: " + music.position);
        //Log.v("MusicPlayerService", "Duration: " + music.duration);

        MediaMetadataCompat metadata = new MediaMetadataCompat.Builder()
                .putString(MediaMetadata.METADATA_KEY_TITLE, music.title)
                .putString(MediaMetadata.METADATA_KEY_ARTIST, music.artist)
                .putString(MediaMetadata.METADATA_KEY_ALBUM, music.album)
                .putBitmap(MediaMetadata.METADATA_KEY_ART, music.image)
                .putLong(MediaMetadata.METADATA_KEY_DURATION, music.duration)
                .build();

        session.setMetadata(metadata);

        int playbackSpeed = music.isPlaying ? 1 : 0;
        int playbackState = music.isPlaying
                ? PlaybackStateCompat.STATE_PLAYING
                : PlaybackStateCompat.STATE_PAUSED;

        boolean showPrevNext = music.showPrevious || music.showNext;

        PlaybackStateCompat state = new PlaybackStateCompat.Builder()
                .setState(playbackState, music.position, playbackSpeed)
                .setActions(PlaybackStateCompat.ACTION_PLAY_PAUSE |
                        PlaybackStateCompat.ACTION_PLAY |
                        PlaybackStateCompat.ACTION_PAUSE |
                        PlaybackStateCompat.ACTION_SEEK_TO |
                        PlaybackStateCompat.ACTION_STOP |
                        PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS |
                        PlaybackStateCompat.ACTION_SKIP_TO_NEXT)
                .build();

        session.setPlaybackState(state);
        session.setActive(true);

        MediaStyle mediaStyle = new MediaStyle()
                .setMediaSession(session.getSessionToken())
                // For backwards compatibility with Android L and earlier.
                .setShowCancelButton(true)
                .setCancelButtonIntent(pendingIntent(4, MusicAction.stop));

        if (!music.isLoading) {
            if (showPrevNext) {
                mediaStyle.setShowActionsInCompactView(1, 2);
            } else {
                mediaStyle.setShowActionsInCompactView(0);
            }
        }
        //普通notification用到的视图
        RemoteViews normalView = new RemoteViews(getPackageName(), R.layout.notification);

//                normalView.setImageViewUri(R.id.action_image, new Uri.Builder().scheme("https").appendPath("temp1.inkroom.cn/temp/quiet/s.jpg").build());
        normalView.setImageViewBitmap(R.id.action_image, music.image);
        normalView.setTextViewText(R.id.title_name, music.title);
        normalView.setTextViewText(R.id.author_name, music.artist);
        normalView.setOnClickPendingIntent(R.id.media_previous,pendingIntent(1,MusicAction.previous));
        normalView.setOnClickPendingIntent(R.id.media_play,pendingIntent(2,MusicAction.play));
        normalView.setOnClickPendingIntent(R.id.media_pause,pendingIntent(2,MusicAction.pause));
        normalView.setOnClickPendingIntent(R.id.media_next,pendingIntent(3,MusicAction.next));


        //显示bigView的notification用到的视图
        RemoteViews bigView = new RemoteViews(getPackageName(), R.layout.big_notification);
        bigView.setImageViewBitmap(R.id.action_image, music.image);
        bigView.setTextViewText(R.id.title_name, music.title);
        bigView.setTextViewText(R.id.author_name, music.artist);
        bigView.setProgressBar(R.id.progress, music.duration, music.position, false);

        bigView.setOnClickPendingIntent(R.id.media_previous,pendingIntent(1,MusicAction.previous));
        bigView.setOnClickPendingIntent(R.id.media_play,pendingIntent(2,MusicAction.play));
        bigView.setOnClickPendingIntent(R.id.media_pause,pendingIntent(2,MusicAction.pause));
        bigView.setOnClickPendingIntent(R.id.media_next,pendingIntent(3,MusicAction.next));

        if (music.isPlaying){
            bigView.setViewVisibility(R.id.media_play, View.GONE);
            bigView.setViewVisibility(R.id.media_pause, View.VISIBLE);
            normalView.setViewVisibility(R.id.media_play, View.GONE);
            normalView.setViewVisibility(R.id.media_pause, View.VISIBLE);
        }else{
            bigView.setViewVisibility(R.id.media_play, View.VISIBLE);
            bigView.setViewVisibility(R.id.media_pause, View.GONE);
            normalView.setViewVisibility(R.id.media_play, View.VISIBLE);
            normalView.setViewVisibility(R.id.media_pause, View.GONE);
        }


        NotificationCompat.Builder builder = new NotificationCompat
                .Builder(getApplicationContext(), channelId)
                .setContentTitle(music.title)
                .setContentText(music.artist)
                .setLargeIcon(music.image)
                .setContent(normalView)//设置普通notification视图
                .setCustomBigContentView(bigView)//设置显示bigView的notification视图
                .setSmallIcon(R.drawable.notification_icon)
                .setOngoing(music.isPlaying)
//                .setStyle(mediaStyle)
                ;

        int secpos = music.position / 1000;
        int hour = secpos / 3600;
        int minute = (secpos % 3600) / 60;
        int second = secpos % 60;

        Calendar now = Calendar.getInstance();
        now.set(Calendar.HOUR_OF_DAY, minute);
        now.set(Calendar.MINUTE, second);
        now.set(Calendar.SECOND, 0);
        long when = now.getTimeInMillis();
        builder.setUsesChronometer(false);
        builder.setWhen(when);

        /*if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            builder.setUsesChronometer(true);
        } else {
            builder.setUsesChronometer(false);
        }*/

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder.setChannelId(channelId);
        }

        /*NotificationCompat.Action previous = mediaAction(
            R.drawable.media_previous, "Previous", PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS);
        NotificationCompat.Action pause = mediaAction(
            R.drawable.media_pause, "Pause", PlaybackStateCompat.ACTION_PAUSE);
        NotificationCompat.Action play = mediaAction(
            R.drawable.media_play, "Play", PlaybackStateCompat.ACTION_PLAY);
        NotificationCompat.Action next = mediaAction(
            R.drawable.media_next, "Next", PlaybackStateCompat.ACTION_SKIP_TO_NEXT);*/

        NotificationCompat.Action previous = mediaAction(
                R.drawable.media_previous, 1, "Previous", MusicAction.previous);
        NotificationCompat.Action pause = mediaAction(
                R.drawable.media_pause, 2, "Pause", MusicAction.pause);
        NotificationCompat.Action play = mediaAction(
                R.drawable.media_play, 2, "Play", MusicAction.play);
        NotificationCompat.Action next = mediaAction(
                R.drawable.media_next, 3, "Next", MusicAction.next);

        if (showPrevNext) {
            builder.addAction(previous);
        }

        if (!music.isLoading) {
            if (music.isPlaying) {
                builder.addAction(pause);
            } else {
                builder.addAction(play);
            }
        }

        if (showPrevNext) {
            builder.addAction(next);
        }

        // When notification is deleted (when playback is paused and
        // notification can be deleted) fire MediaButtonPendingIntent
        // with ACTION_PAUSE.
        builder.setDeleteIntent(pendingIntent(2, MusicAction.stop));

        Intent notificationIntent = getApplicationContext().getPackageManager().getLaunchIntentForPackage(getPackageName());
        builder.setContentIntent(PendingIntent.getActivity(getApplicationContext(), 0,
                notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT));
        Notification n = builder.build();
        startForeground(notifyId, n);
        if (manager != null) {
            manager.notify(notifyId, n);
        }
    }

    private void detachNotifyFromService() {
        //Log.v("MusicPlayerService", "detachNotifyFromService");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_DETACH);
        } else {
            stopForeground(false);
        }
    }

    public void cancel() {
        //Log.v("MusicPlayerService", "cancelNotification");
        if (manager != null) {
            manager.cancel(notifyId);
        }
    }
}
