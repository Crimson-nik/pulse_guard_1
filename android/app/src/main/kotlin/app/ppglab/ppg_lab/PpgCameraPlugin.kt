package app.ppglab.ppg_lab

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.util.Size
import android.view.WindowManager
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Streams one averaged colour sample per camera frame.
 *
 * The whole point of doing this in Kotlin rather than behind a generic camera
 * plugin is control over the two things the paper's method depends on: the
 * exact pixel format (YUV 420, converted per frame the way the paper
 * describes) and the arrival time of each frame, which is what makes the
 * sampled frame rate measurable instead of assumed.
 *
 * Only the mean red and mean green of each frame cross the channel. A full
 * frame would be 900 KB per frame, thirty times a second, for information the
 * maths throws away immediately.
 */
class PpgCameraPlugin(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val methodChannel = MethodChannel(messenger, "app.ppglab/camera")
    private val eventChannel = EventChannel(messenger, "app.ppglab/frames")

    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    private var eventSink: EventChannel.EventSink? = null
    private var provider: ProcessCameraProvider? = null
    private var analysis: ImageAnalysis? = null
    private var camera: Camera? = null
    private var startedAtNanos = 0L
    private var pendingPermission: MethodChannel.Result? = null

    /** Grid step for the pixel average. 4 means one sample per 16 pixels. */
    private val sampleStep = 4

    fun attach() {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    fun detach() {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        stopCapture()
        executor.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasFlash" -> result.success(hasFlash())
            "requestPermission" -> requestCameraPermission(result)
            "start" -> startCapture(result)
            "stop" -> {
                stopCapture()
                result.success(null)
            }
            "torch" -> {
                val on = call.argument<Boolean>("on") ?: false
                setTorch(on)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != REQUEST_CAMERA) return false
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingPermission?.success(granted)
        pendingPermission = null
        return true
    }

    private fun hasFlash(): Boolean {
        return activity.packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH)
    }

    private fun requestCameraPermission(result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }
        pendingPermission?.success(false)
        pendingPermission = result
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(Manifest.permission.CAMERA),
            REQUEST_CAMERA,
        )
    }

    private fun startCapture(result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            result.error("no_permission", "Camera permission has not been granted", null)
            return
        }
        val future = ProcessCameraProvider.getInstance(activity)
        future.addListener({
            try {
                val cameraProvider = future.get()
                provider = cameraProvider

                val resolution = ResolutionSelector.Builder()
                    .setResolutionStrategy(
                        ResolutionStrategy(
                            Size(640, 480),
                            ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER,
                        ),
                    )
                    .build()

                val analyzer = ImageAnalysis.Builder()
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .setResolutionSelector(resolution)
                    .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888)
                    .build()
                analyzer.setAnalyzer(executor) { image -> analyse(image) }
                analysis = analyzer

                cameraProvider.unbindAll()
                camera = cameraProvider.bindToLifecycle(
                    activity as LifecycleOwner,
                    CameraSelector.DEFAULT_BACK_CAMERA,
                    analyzer,
                )
                startedAtNanos = System.nanoTime()
                setTorch(true)
                keepScreenOn(true)
                result.success(true)
            } catch (error: Exception) {
                result.error("camera_start_failed", error.message, null)
            }
        }, ContextCompat.getMainExecutor(activity))
    }

    private fun stopCapture() {
        setTorch(false)
        keepScreenOn(false)
        camera = null
        analysis?.clearAnalyzer()
        analysis = null
        provider?.unbindAll()
        startedAtNanos = 0L
    }

    /**
     * Holds the screen awake for the length of a capture.
     *
     * Thirty seconds is close to the default screen timeout on many phones,
     * and a screen that sleeps pauses the activity and unbinds the camera,
     * which ends the frame stream halfway through the measurement. The flag
     * is cleared as soon as the capture stops, so it does not keep the display
     * on while the app is merely being read.
     */
    private fun keepScreenOn(on: Boolean) {
        try {
            if (on) {
                activity.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            } else {
                activity.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            }
        } catch (_: Exception) {
            // A window that refuses the flag is not a reason to fail a capture.
        }
    }

    private fun setTorch(on: Boolean) {
        val control = camera?.cameraControl ?: return
        try {
            control.enableTorch(on)
        } catch (_: Exception) {
            // Some devices refuse the torch while another app holds the camera.
            // A dead torch is a bad reading, not a crash.
        }
    }

    /**
     * Averages a grid of pixels per frame.
     *
     * YUV to RGB uses the BT.601 full range matrix, which is what Android's
     * own conversion uses for camera frames. Values are clamped to 0..255 so
     * that signal clipping shows up in the stored samples and can be reported
     * as a quality problem rather than silently shaping the waveform.
     */
    private fun analyse(image: ImageProxy) {
        val sink = eventSink
        val start = startedAtNanos
        if (sink == null || start == 0L) {
            image.close()
            return
        }
        try {
            val width = image.width
            val height = image.height
            val yPlane = image.planes[0]
            val uPlane = image.planes[1]
            val vPlane = image.planes[2]
            val yBuffer = yPlane.buffer
            val uBuffer = uPlane.buffer
            val vBuffer = vPlane.buffer

            var sumR = 0.0
            var sumG = 0.0
            var count = 0

            var y = 0
            while (y < height) {
                val yRow = y * yPlane.rowStride
                val uvRow = (y / 2)
                var x = 0
                while (x < width) {
                    val yValue = yBuffer.get(yRow + x).toInt() and 0xFF
                    val uIndex = uvRow * uPlane.rowStride + (x / 2) * uPlane.pixelStride
                    val vIndex = uvRow * vPlane.rowStride + (x / 2) * vPlane.pixelStride
                    val uValue = (uBuffer.get(uIndex).toInt() and 0xFF) - 128
                    val vValue = (vBuffer.get(vIndex).toInt() and 0xFF) - 128

                    val r = (yValue + 1.402 * vValue).coerceIn(0.0, 255.0)
                    val g = (yValue - 0.344136 * uValue - 0.714136 * vValue)
                        .coerceIn(0.0, 255.0)
                    sumR += r
                    sumG += g
                    count++
                    x += sampleStep
                }
                y += sampleStep
            }

            if (count == 0) {
                image.close()
                return
            }

            val elapsedMs = (System.nanoTime() - start) / 1_000_000L
            val payload = HashMap<String, Any>(4)
            payload["r"] = sumR / count
            payload["g"] = sumG / count
            payload["t"] = elapsedMs
            payload["n"] = count

            mainHandler.post { sink.success(payload) }
        } catch (error: Exception) {
            mainHandler.post {
                sink.error("frame_failed", error.message, null)
            }
        } finally {
            image.close()
        }
    }

    companion object {
        private const val REQUEST_CAMERA = 4711
    }
}
