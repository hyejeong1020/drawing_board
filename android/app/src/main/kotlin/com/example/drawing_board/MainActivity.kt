package com.example.drawing_board

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Environment
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.download_manager"
    private val REQUEST_WRITE_STORAGE = 112

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestWritePermission()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "downloadFile") {
                val path = call.argument<String>("path")
                if (path != null) {
                    try {
                        copyFileToDownloads(path)
                        result.success(null)
                    } catch (e: IOException) {
                        result.error("IO_EXCEPTION", e.message, null)
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun requestWritePermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)
            != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                REQUEST_WRITE_STORAGE
            )
        }
    }

    @Throws(IOException::class)
    private fun copyFileToDownloads(sourceFilePath: String) {
        val sourceFile = File(sourceFilePath)
        val downloadsDir =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        val destinationFile = File(downloadsDir, sourceFile.name)

        FileInputStream(sourceFile).use { input ->
            FileOutputStream(destinationFile).use { output ->
                input.copyTo(output)
            }
        }
    }
}