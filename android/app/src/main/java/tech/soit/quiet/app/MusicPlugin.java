package tech.soit.quiet.app;

import android.app.Activity;
import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.support.v4.media.session.MediaSessionCompat;
import android.util.Log;


import java.io.File;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MusicPlugin extends BroadcastReceiver implements
        FlutterPlugin, MethodCallHandler, ActivityAware,
        Application.ActivityLifecycleCallbacks,
        AudioManager.OnAudioFocusChangeListener {

    private MethodChannel channel;
    private Context context;
    private Activity activity;
    private MusicPlayer player;
    private MusicPlayerService service;

    private AudioManager audioManager;
    private AudioFocusRequest audioFocus;

    private final Music music = new Music();
    private boolean bound = false;
    // 是否被中断，用在响应操作上
    private boolean abort = false;

    private final Runnable onPositionUpdated = () -> {
        Log.v("MusicPlayerPlugin", "onPositionUpdated");
        music.position = player.getCurrentPosition();
        music.duration = player.getDuration();

        if (service != null) {
            service.showNotification(music);
        }
    };

    private final ServiceConnection connection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder _service) {
            //Log.v("MusicPlayerPlugin", "onServiceConnected");
            bound = true;
            service = ((MusicPlayerService.LocalBinder) _service).service;
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            //Log.v("MusicPlayerPlugin", "onServiceDisconnected");
            service.cancel();
            bound = false;
            service = null;
        }
    };

    private final AudioAttributes audioAttributes = new AudioAttributes.Builder()
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .build();

    private final BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (AudioManager.ACTION_AUDIO_BECOMING_NOISY.equals(intent.getAction())) {
                Log.v("MusicPlayer", "onReceive ACTION_AUDIO_BECOMING_NOISY");
                pause();
            }
        }
    };

    private final MediaSessionCompat.Callback sessionCallback = new MediaSessionCompat.Callback() {
        @Override
        public void onSeekTo(long pos) {
            Log.v("MusicPlayerCallback", "onSeekTo");
            if (pos > 0) {
                player.seek((int) pos);
            }
        }

        @Override
        public void onPlay() {
            Log.v("MusicPlayerCallback", "onPlay");
            resume();
        }

        @Override
        public void onPause() {
            Log.v("MusicPlayerCallback", "onPause");
            pause();
        }

        @Override
        public void onStop() {
            Log.v("MusicPlayerCallback", "onStop");
            stop();
        }

        @Override
        public void onSkipToNext() {
            Log.v("MusicPlayerCallback", "onSkipToNext");
            player.playNext();
        }

        @Override
        public void onSkipToPrevious() {
            Log.v("MusicPlayerCallback", "onSkipToPrevious");
            player.playPrevious();
        }
    };

    @Override
    public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
        Log.v("MusicPlayerPlugin", "onAttachedToEngine");
        channel = new MethodChannel(
                flutterPluginBinding.getBinaryMessenger(), "salkuadrat/musicplayer");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "prepare":
                prepare(call);
                result.success(true);
                break;
            case "play":
                play(call);
                result.success(true);
                break;
            case "pause":
                pause();
                result.success(true);
                break;
            case "resume":
                resume();
                result.success(true);
                break;
            case "stop":
                stop();
                result.success(true);
                break;
            case "cancel":
                cancel();
                result.success(true);
                break;
            case "seek":
                seek(call, result);
                break;
            case "dispose":
                dispose();
                result.success(true);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void startService() {
        if (!bound && activity != null) {
            Log.v("MusicPlayerPlugin", "Starting service");
            Intent intent = new Intent(activity, MusicPlayerService.class);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                activity.startForegroundService(intent);
            } else {
                activity.startService(intent);
            }

            Log.v("MusicPlayerPlugin", "Binding service");
            activity.bindService(intent, connection, Context.BIND_AUTO_CREATE);
        }
    }

    private void registerNoisyFilter() {
        try {
            context.unregisterReceiver(receiver);
        } catch (IllegalArgumentException e) {
            //e.printStackTrace();
        }

        IntentFilter noisyFilter = new IntentFilter(AudioManager.ACTION_AUDIO_BECOMING_NOISY);
        context.registerReceiver(receiver, noisyFilter);
    }

    private void prepare(MethodCall call) {
        startService();
        registerNoisyFilter();

        if (service != null) {
            service.cancel();
        }

        String image = call.argument("image");

        if (image != null) {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inPreferredConfig = Bitmap.Config.ARGB_8888;
            music.image = BitmapFactory.decodeFile(
                    new File(context.getCacheDir(), image).getAbsolutePath(), options);
        } else {
            music.image = null;
        }

        Integer duration = call.argument("duration");
        Boolean sp = call.argument("showPrevious");
        Boolean sn = call.argument("showNext");
        Boolean autoStart = call.argument("autostart");

        music.id = call.argument("id");
        music.title = call.argument("title");
        music.artist = call.argument("artist");
        music.album = call.argument("album");
        music.imageUrl = call.argument("imageUrl");
        music.duration = duration != null ? duration : 0;
        music.showPrevious = sp != null && sp;
        music.showNext = sn != null && sn;
        music.isLoading = true;
        music.isPlaying = false;
        music.position = 0;
        music.autoStart = autoStart != null && autoStart;
        if (service != null) {
            service.showNotification(music);
        }
    }

    private void play(MethodCall call) {
        startService();
        registerNoisyFilter();

        String image = call.argument("image");

        if (image != null) {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inPreferredConfig = Bitmap.Config.ARGB_8888;
            music.image = BitmapFactory.decodeFile(
                    new File(context.getCacheDir(), image).getAbsolutePath(), options);
        } else {
            music.image = null;
        }

        String url = call.argument("url");
        Integer duration = call.argument("duration");
        Boolean sp = call.argument("showPrevious");
        Boolean sn = call.argument("showNext");
        Boolean autoStart = call.argument("autoStart");

        music.id = call.argument("id");
        music.title = call.argument("title");
        music.artist = call.argument("artist");
        music.album = call.argument("album");
        music.imageUrl = call.argument("imageUrl");
        music.duration = duration != null ? duration : 0;
        music.showPrevious = sp != null && sp;
        music.showNext = sn != null && sn;
        music.isLoading = false;
        music.isPlaying = true;

        player.play(url, autoStart != null && autoStart);

        if (service != null) {
            service.showNotification(music);
        }
    }

    private void pause() {
        music.position = player.getCurrentPosition();
        music.duration = player.getDuration();
        music.isLoading = false;
        music.isPlaying = false;
        player.pause();
        abort = false;

        if (service != null) {
            service.showNotification(music);
        }
    }

    private void resume() {
        music.position = player.getCurrentPosition();
        music.duration = player.getDuration();
        music.isLoading = false;
        music.isPlaying = true;
        player.resume();

        if (service != null) {
            service.showNotification(music);
        }
    }

    private void seek(MethodCall call, Result result) {
        Integer position = (Integer) call.arguments;

        if (position != null) {
            player.seek(position);
        }

        result.success(position);
    }

    private void stop() {
        try {
            context.unregisterReceiver(receiver);
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (service != null) {
            service.cancel();
        }

        music.isPlaying = false;
        music.isLoading = false;
        player.stop();
        abort = false;
    }

    private void cancel() {
        if (service != null) {
            service.cancel();
        }
    }

    private void dispose() {
        cancel();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioManager.abandonAudioFocusRequest(audioFocus);
        }

        player.close();
        music.session.release();
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        //Log.v("MusicPlayerPlugin", "onDetachedFromEngine");
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        //Log.v("MusicPlayerPlugin", "onAttachedToActivity");
        activity = binding.getActivity();
        context = activity.getApplicationContext();
        music.session = new MediaSessionCompat(context, "MusicPlayerService");
        // get notif from notification action (e.g., when seek to from seekbar)
        music.session.setCallback(sessionCallback);

        audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocus = new AudioFocusRequest
                    .Builder(AudioManager.AUDIOFOCUS_GAIN)
                    .setAudioAttributes(audioAttributes)
                    .setWillPauseWhenDucked(true)
                    .setAcceptsDelayedFocusGain(true)
                    .setOnAudioFocusChangeListener(this)
                    .build();

            audioManager.requestAudioFocus(audioFocus);
        }

        player = new MusicPlayer(channel, activity, onPositionUpdated);

        IntentFilter filter = new IntentFilter();
        filter.addAction(MusicAction.PAUSE);
        filter.addAction(MusicAction.PLAY);
        filter.addAction(MusicAction.PREVIOUS);
        filter.addAction(MusicAction.NEXT);
        filter.addAction(MusicAction.STOP);
        filter.addAction(MusicAction.CANCEL);
        context.registerReceiver(this, filter);
        activity.getApplication().registerActivityLifecycleCallbacks(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        //Log.v("MusicPlayerPlugin", "onDetachedFromActivityForConfigChanges");
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        //Log.v("MusicPlayerPlugin", "onReattachedToActivityForConfigChanges");
    }

    @Override
    public void onDetachedFromActivity() {
        //Log.v("MusicPlayerPlugin", "onDetachedFromActivity");
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        //Log.v("MusicPlayerPlugin", "onReceive");
        switch (intent.getAction()) {
            case MusicAction.PLAY:
                Log.v("MusicPlayerPlugin", "onReceive PLAY");
                resume();
                break;
            case MusicAction.PAUSE:
                Log.v("MusicPlayerPlugin", "onReceive PAUSE");
                pause();
                break;
            case MusicAction.PREVIOUS:
                Log.v("MusicPlayerPlugin", "onReceive PREVIOUS");
                if (music.showPrevious) {
                    music.isPlaying = true;
                    player.playPrevious();
                    service.showNotification(music);
                }
                break;
            case MusicAction.NEXT:
                Log.v("MusicPlayerPlugin", "onReceive NEXT");
                if (music.showNext) {
                    music.isPlaying = true;
                    player.playNext();
                    service.showNotification(music);
                }
                break;
            case MusicAction.STOP:
                Log.v("MusicPlayerPlugin", "onReceive STOP");
            case MusicAction.CANCEL:
                Log.v("MusicPlayerPlugin", "onReceive CANCEL");
                stop();
                break;
        }
    }

    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
        //Log.v("MusicPlayerPlugin", "onActivityCreated");
    }

    @Override
    public void onActivityStarted(Activity activity) {
        //Log.v("MusicPlayerPlugin", "onActivityStarted");
    }

    @Override
    public void onActivityResumed(Activity activity) {
        //Log.v("MusicPlayerPlugin", "onActivityResumed");
    }

    @Override
    public void onActivityPaused(Activity activity) {
        //Log.v("MusicPlayerPlugin", "onActivityPaused");
    }

    @Override
    public void onActivityStopped(Activity activity) {
        //Log.v("MusicPlayerPlugin", "onActivityStopped");
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
        //Log.v("MusicPlayerPlugin", "onActivitySaveInstanceState");
    }

    @Override
    public void onActivityDestroyed(Activity activity) {
        //Log.v("MusicPlayerPlugin", "onActivityDestroyed");
        stop();
        dispose();
    }

    @Override
    public void onAudioFocusChange(int focusChange) {
        switch (focusChange) {
            case AudioManager.AUDIOFOCUS_GAIN:
                Log.v("player focus", "onReceive AUDIOFOCUS_GAIN 中断 = " + abort);
                // 被打断播放的才继续播放
                if (abort)
                    resume();
                break;
            case AudioManager.AUDIOFOCUS_LOSS:
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                Log.v("player focus", "onReceive AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK 中断 = " + abort);
                if (player.isPlaying()) {// 正在播放，当前音乐被打断，否则没有播放，那就不存在打断
                    pause();
                    abort = true;
                }
                break;
        }
    }
}
