package com.tubigtrack.tubig_track

import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Environment
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "com.tubigtrack.tubig_track/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "initPublicStorage" -> {
                        result.success(initPublicStorage())
                    }
                    "openFolderInFilesApp" -> {
                        val relativePath = call.argument<String>("relativePath")
                        val absolutePath = call.argument<String>("absolutePath")
                        result.success(openFolderInFilesApp(relativePath, absolutePath))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Creates Internal Storage/TubigTrack/ and subfolders when writable.
     * Returns the absolute root path, or null when public storage is unavailable.
     */
    private fun initPublicStorage(): String? {
        if (!Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState())) {
            return null
        }

        val root = File(Environment.getExternalStorageDirectory(), "TubigTrack")
        val subfolders = listOf(
            "Backups",
            "Archives",
            "CSV",
            "Reports",
            "Recovery",
            "Recovery/RestoreLogs",
        )

        return try {
            if (!root.exists() && !root.mkdirs()) return null
            for (sub in subfolders) {
                val dir = File(root, sub)
                if (!dir.exists() && !dir.mkdirs()) return null
            }
            val probe = File(root, ".tubigtrack_probe")
            probe.writeText("ok")
            if (!probe.exists()) return null
            probe.delete()
            root.absolutePath
        } catch (_: Exception) {
            null
        }
    }

    /**
     * Opens a folder in the system Files app using a DocumentsContract URI.
     */
    private fun openFolderInFilesApp(relativePath: String?, absolutePath: String?): Boolean {
        return try {
            if (!absolutePath.isNullOrBlank()) {
                openPublicDocumentFolder(absolutePathToDocumentId(absolutePath))
            } else {
                val segment = relativePath?.trim('/')?.takeIf { it.isNotEmpty() }
                val docPath = if (segment == null) "TubigTrack" else "TubigTrack/$segment"
                openPublicDocumentFolder("primary:$docPath")
            }
        } catch (_: ActivityNotFoundException) {
            false
        } catch (_: Exception) {
            false
        }
    }

    private fun absolutePathToDocumentId(absolutePath: String): String {
        val externalRoot = Environment.getExternalStorageDirectory().absolutePath
        val normalized = absolutePath.replace('\\', '/')
        val root = externalRoot.replace('\\', '/')
        val suffix = if (normalized.startsWith(root)) {
            normalized.removePrefix(root).trimStart('/')
        } else {
            normalized.substringAfter("TubigTrack").trimStart('/').let {
                if (it.isEmpty()) "TubigTrack" else "TubigTrack/$it"
            }
        }
        return "primary:$suffix"
    }

    private fun openPublicDocumentFolder(documentId: String): Boolean {
        val uri = DocumentsContract.buildDocumentUri(
            "com.android.externalstorage.documents",
            documentId,
        )
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, DocumentsContract.Document.MIME_TYPE_DIR)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
        return true
    }
}
