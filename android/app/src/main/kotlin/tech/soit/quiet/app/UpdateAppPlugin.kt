import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Parcel
import android.os.Parcelable
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File

/**
 * apk文件类型
 */
const val apkType = "application/vnd.android.package-archive"

@SuppressLint("ParcelCreator")
class UpdateAppPlugin() : FlutterPlugin, MethodChannel.MethodCallHandler, Parcelable {
    private lateinit var channel: MethodChannel

    private lateinit var context: Context

    constructor(parcel: Parcel) : this() {

    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "quiet.update.app.channel.name"
        )
        context = flutterPluginBinding.applicationContext
        channel.setMethodCallHandler(this)
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), "quiet.update.app.channel.name")
            val updateAppPlugin = UpdateAppPlugin()
            //初始化上下文
            updateAppPlugin.context = registrar.context()
            channel.setMethodCallHandler(updateAppPlugin)
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "installApk" -> result.success(installApk( context,  call.argument<String>("path")))
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun writeToParcel(parcel: Parcel, flags: Int) {

    }

    override fun describeContents(): Int {
        return 0
    }

//    companion object CREATOR : Parcelable.Creator<UpdateAppPlugin> {
//        override fun createFromParcel(parcel: Parcel): UpdateAppPlugin {
//            return UpdateAppPlugin(parcel)
//        }
//
//        override fun newArray(size: Int): Array<UpdateAppPlugin?> {
//            return arrayOfNulls(size)
//        }
//    }

}
fun installApk(context: Context, file: String?) {
    if(file!=null && file.isNotEmpty()){
        val intent = Intent(Intent.ACTION_VIEW)
        //设置flag
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            //7.0及以上
            val uri = FileProvider.getUriForFile(
                context, context.applicationInfo.packageName + "" +
                        ".update_provider", File(file)
            )
            intent.setDataAndType(uri, apkType)

            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        } else {
            //7.0以下, 设置数据
            intent.setDataAndType(Uri.fromFile(File(file)), apkType)
        }
        //启动activity
        context.startActivity(intent)
    }

}
class UpdateFileProvider : FileProvider()