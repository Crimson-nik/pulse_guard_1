package app.ppglab.ppg_lab

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var cameraPlugin: PpgCameraPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val plugin = PpgCameraPlugin(this, flutterEngine.dartExecutor.binaryMessenger)
        plugin.attach()
        cameraPlugin = plugin
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        val handled = cameraPlugin?.onRequestPermissionsResult(requestCode, grantResults) ?: false
        if (!handled) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
    }

    override fun onDestroy() {
        cameraPlugin?.detach()
        cameraPlugin = null
        super.onDestroy()
    }
}
