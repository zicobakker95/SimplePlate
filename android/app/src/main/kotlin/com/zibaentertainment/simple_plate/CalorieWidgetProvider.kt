package com.zibaentertainment.simple_plate

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class CalorieWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val data = HomeWidgetPlugin.getData(context)
        val calories = data.getFloat("calories", 0f).toInt()
        val goal = data.getInt("goal_calories", 2000)
        val remaining = (goal - calories).coerceAtLeast(0)

        val views = RemoteViews(context.packageName, R.layout.home_widget_layout)
        views.setTextViewText(R.id.widget_calories, calories.toString())
        views.setTextViewText(R.id.widget_remaining, "$remaining left")
        views.setTextViewText(R.id.widget_goal, "goal $goal")

        // Tap the widget to open the app
        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_calories, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
