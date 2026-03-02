package com.smartphonecleaner.storageboost

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Environment
import android.os.StatFs
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.smartphonecleaner.storageboost/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getStorageStats" -> {
                    val stats = getStorageStats()
                    result.success(stats)
                }
                "getRamUsage" -> {
                    val stats = getRamUsage()
                    result.success(stats)
                }
                "killBackgroundProcesses" -> {
                    killBackgroundProcesses()
                    result.success(true)
                }
                "getInstalledApps" -> {
                    val apps = getInstalledApps()
                    result.success(apps)
                }
                "uninstallApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        uninstallApp(packageName)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is null", null)
                    }
                }
                "checkUsageStatsPermission" -> {
                    result.success(checkUsageStatsPermission())
                }
                "openUsageStatsSettings" -> {
                    openUsageStatsSettings()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun killBackgroundProcesses() {
        val activityManager = getSystemService(android.content.Context.ACTIVITY_SERVICE) as android.app.ActivityManager
        val packages = activityManager.runningAppProcesses
        if (packages != null) {
            for (packageInfo in packages) {
                if (packageInfo.processName != packageName) { // Don't kill self
                    activityManager.killBackgroundProcesses(packageInfo.processName)
                }
            }
        }
        // Hint to system to run GC
        System.gc()
    }

    private fun getRamUsage(): Map<String, Long> {
        val memoryInfo = android.app.ActivityManager.MemoryInfo()
        val activityManager = getSystemService(android.content.Context.ACTIVITY_SERVICE) as android.app.ActivityManager
        activityManager.getMemoryInfo(memoryInfo)

        return mapOf(
            "totalRam" to memoryInfo.totalMem,
            "availableRam" to memoryInfo.availMem,
            "usedRam" to memoryInfo.totalMem - memoryInfo.availMem
        )
    }

    private fun getStorageStats(): Map<String, Long> {
        // Internal Shared Storage (User accessible)
        val sharedPath = Environment.getExternalStorageDirectory()
        val sharedStat = StatFs(sharedPath.path)
        val sharedTotal = sharedStat.blockCountLong * sharedStat.blockSizeLong
        val sharedAvailable = sharedStat.availableBlocksLong * sharedStat.blockSizeLong

        // System Root Storage (Total Disk)
        val rootPath = Environment.getRootDirectory()
        val rootStat = StatFs(rootPath.path)
        
        // Data directory is usually where the bulk of usage (apps/system) lived
        val dataPath = Environment.getDataDirectory()
        val dataStat = StatFs(dataPath.path)
        val dataTotal = dataStat.blockCountLong * dataStat.blockSizeLong
        val dataAvailable = dataStat.availableBlocksLong * dataStat.blockSizeLong

        // For most users, "Total Storage" in settings corresponds to the physical disk size
        // which is usually sharedTotal + some system overhead.
        // We'll return the shared storage stats but also the data partition stats which includes apps.
        
        return mapOf(
            "totalSpace" to sharedTotal, // Keep existing keys for compatibility
            "availableSpace" to sharedAvailable,
            "usedSpace" to sharedTotal - sharedAvailable,
            "dataTotalSpace" to dataTotal,
            "dataAvailableSpace" to dataAvailable
        )
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val packageManager = packageManager
        val apps = packageManager.getInstalledApplications(android.content.pm.PackageManager.GET_META_DATA)
        val appList = mutableListOf<Map<String, Any?>>()

        // For sizing, we need StorageStatsManager (API 26+)
        val storageStatsManager = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            getSystemService(android.app.usage.StorageStatsManager::class.java)
        } else {
            null
        }

        for (app in apps) {
            // Filter out system apps if they are not launchable (optional, but cleaner)
            // if (packageManager.getLaunchIntentForPackage(app.packageName) == null) continue

            val appInfoMap = mutableMapOf<String, Any?>()
            appInfoMap["packageName"] = app.packageName
            appInfoMap["appName"] = packageManager.getApplicationLabel(app).toString()
            appInfoMap["isSystemApp"] = (app.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0
            
            // Icon as ByteArray
            try {
                val icon = packageManager.getApplicationIcon(app)
                if (icon is android.graphics.drawable.BitmapDrawable) {
                    val stream = java.io.ByteArrayOutputStream()
                    icon.bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
                    appInfoMap["icon"] = stream.toByteArray()
                }
            } catch (e: Exception) {}

            // Size information (requires special permission usually, but let's try)
            if (storageStatsManager != null) {
                try {
                    val storageStats = storageStatsManager.queryStatsForPackage(app.storageUuid, app.packageName, android.os.Process.myUserHandle())
                    appInfoMap["size"] = storageStats.appBytes + storageStats.dataBytes
                    appInfoMap["cacheSize"] = storageStats.cacheBytes
                } catch (e: Exception) {
                    appInfoMap["size"] = 0L
                    appInfoMap["cacheSize"] = 0L
                }
            }

            appList.add(appInfoMap)
        }
        return appList
    }

    private fun uninstallApp(packageName: String) {
        val intent = android.content.Intent(android.content.Intent.ACTION_DELETE)
        intent.data = android.net.Uri.parse("package:$packageName")
        startActivity(intent)
    }

    private fun checkUsageStatsPermission(): Boolean {
        val appOps = getSystemService(android.content.Context.APP_OPS_SERVICE) as android.app.AppOpsManager
        val mode = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(android.app.AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), packageName)
        } else {
            appOps.checkOpNoThrow(android.app.AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), packageName)
        }
        return mode == android.app.AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageStatsSettings() {
        val intent = android.content.Intent(android.provider.Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }
}
