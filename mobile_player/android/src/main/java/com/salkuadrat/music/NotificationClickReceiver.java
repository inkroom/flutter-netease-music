package com.salkuadrat.music;
import io.flutter.embedding.android.FlutterActivity;
import android.content.Intent;
import android.content.Context;
import android.util.Log;
public class NotificationClickReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        //todo 跳转之前要处理的逻辑
        Log.i("TAG", "userClick:我被点击啦！！！ ");
        Intent newIntent = new Intent(context, FlutterActivity.class);
        context.startActivity(newIntent);
    }
}