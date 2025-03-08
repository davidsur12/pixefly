
package com.pixelfy.pixelfy

import android.database.Cursor
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.pixelfy.image_picker"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getImageFolders") {
                result.success(getImageFolders())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getImageFolders(): List<String> {
        val folders = mutableSetOf<String>()
        val projection = arrayOf(MediaStore.Images.Media.DATA)
        val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
        } else {
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        }

        val cursor: Cursor? = contentResolver.query(uri, projection, null, null, null)

        cursor?.use {
            val columnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
            while (it.moveToNext()) {
                val filePath = it.getString(columnIndex)
                val folderPath = File(filePath).parent
                if (folderPath != null) {
                    folders.add(folderPath)
                }
            }
        }
        return folders.toList()
    }
}


/*
package com.pixelfy.pixelfy

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity()
*/