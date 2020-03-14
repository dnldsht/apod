package org.hora.apod

import android.app.WallpaperManager
import android.content.ContentValues
import android.content.Intent
import android.database.Cursor
import android.graphics.BitmapFactory
import android.net.Uri
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File



class MainActivity: FlutterActivity() {

    companion object {
        const val COMMANDS_CHANNEL = "org.hora.wall"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COMMANDS_CHANNEL).setMethodCallHandler { call, result ->
            when(call.method) {
                "home" -> setWallPaper(1, call.arguments as String, result)
                "lock" -> setWallPaper(2, call.arguments as String, result)
                "both" -> setWallPaper(3, call.arguments as String, result)
                "system" -> setWallPaper(4, call.arguments as String, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun setWallPaper(type:Int, name: String, result:MethodChannel.Result) {


        try {
            val wallManager = WallpaperManager.getInstance(applicationContext)
            val f = File(getExternalFilesDir(null), name)

            val bitmap = BitmapFactory.decodeFile(f.absolutePath)

            when (type) {
                1 -> wallManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
                2 -> wallManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
                3 -> wallManager.setBitmap(bitmap)
                4 -> {
//                    val uri = Uri.fromFile(f)
                    val contentURI = getImageContentUri( f)
                    Log.d("asd", contentURI.toString())
                    if (contentURI != null) {
                        Log.d("asd", contentResolver.getType(contentURI))
                    }
                    val intent = Intent(wallManager.getCropAndSetWallpaperIntent(contentURI))
                    val mime = "image/*"
                    intent.setDataAndType(contentURI, mime)
                    startActivityForResult(intent, 2)
                }
            }
            result.success(true)
        } catch (e: Exception) {
            result.error(e.message, e.message, e.message)
        }
    }

    private fun getImageContentUri(imageFile: File): Uri? {
        val filePath = imageFile.absolutePath

        val cursor: Cursor? = context.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI, arrayOf(MediaStore.Images.Media._ID),
                MediaStore.Images.Media.DATA + "=? ", arrayOf(filePath), null)

        return if (cursor != null && cursor.moveToFirst()) {
            val id: Int = cursor.getInt(cursor
                    .getColumnIndex(MediaStore.MediaColumns._ID))
            val baseUri: Uri = Uri.parse("content://media/external/images/media")
            cursor.close()
            Uri.withAppendedPath(baseUri, "" + id)

        } else {
            if (imageFile.exists()) {
                val values = ContentValues()
                values.put(MediaStore.Images.Media.DATA, filePath)
                context.contentResolver.insert(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
            } else {
                null
            }
        }
    }


}
