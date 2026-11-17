package com.example.control_gestantes

import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.CalendarContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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
}
