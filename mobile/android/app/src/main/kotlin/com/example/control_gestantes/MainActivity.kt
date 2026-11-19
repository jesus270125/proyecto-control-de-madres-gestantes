package com.example.control_gestantes

import android.content.ActivityNotFoundException
import android.content.Intent
import android.app.Activity
import android.provider.CalendarContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingPdf: ByteArray? = null
    private var pendingPdfResult: MethodChannel.Result? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rimaykullayki/files")
            .setMethodCallHandler { call, result ->
                if (call.method != "savePdf") { result.notImplemented(); return@setMethodCallHandler }
                val bytes = call.argument<ByteArray>("bytes")
                if (bytes == null || pendingPdfResult != null) { result.error("UNAVAILABLE", "No se pudo guardar el archivo", null); return@setMethodCallHandler }
                pendingPdf = bytes
                pendingPdfResult = result
                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).addCategory(Intent.CATEGORY_OPENABLE)
                    .setType("application/pdf").putExtra(Intent.EXTRA_TITLE, "carne-prenatal.pdf")
                try { startActivityForResult(intent, 7251) }
                catch (e: ActivityNotFoundException) { pendingPdf = null; pendingPdfResult = null; result.error("NO_DOCUMENTS", "No hay selector de archivos", null) }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rimaykullayki/calendar")
            .setMethodCallHandler { call, result ->
                if (call.method != "addEvent") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val start = call.argument<Number>("start")?.toLong()
                if (start == null) {
                    result.error("INVALID_DATE", "Fecha no válida", null)
                    return@setMethodCallHandler
                }
                val intent = Intent(Intent.ACTION_INSERT).setData(CalendarContract.Events.CONTENT_URI)
                    .putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, start)
                    .putExtra(CalendarContract.EXTRA_EVENT_END_TIME, start + 30 * 60 * 1000L)
                    .putExtra(CalendarContract.Events.TITLE, "Recordatorio de salud")
                try {
                    startActivity(intent)
                    result.success(true)
                } catch (e: ActivityNotFoundException) {
                    result.error("NO_CALENDAR", "No hay aplicación de calendario disponible", null)
                }
            }
    }

    @Deprecated("Deprecated in Android")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 7251) return
        val callback = pendingPdfResult
        val bytes = pendingPdf
        pendingPdfResult = null
        pendingPdf = null
        if (resultCode != Activity.RESULT_OK || data?.data == null || bytes == null) { callback?.success(false); return }
        try {
            val stream = contentResolver.openOutputStream(data.data!!) ?: throw IllegalStateException("Archivo no disponible")
            stream.use { it.write(bytes) }
            callback?.success(true)
        } catch (e: Exception) { callback?.error("SAVE_FAILED", "No se pudo guardar el archivo", null) }
    }
}
