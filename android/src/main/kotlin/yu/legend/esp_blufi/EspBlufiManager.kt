package yu.legend.esp_blufi

import android.Manifest
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothGattService
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import blufi.espressif.BlufiCallback
import blufi.espressif.BlufiClient
import blufi.espressif.params.BlufiConfigureParams
import blufi.espressif.params.BlufiParameter
import blufi.espressif.response.BlufiScanResult
import blufi.espressif.response.BlufiStatusResponse
import blufi.espressif.response.BlufiVersionResponse
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class EspBlufiManager(
    private val activityPluginBinding: ActivityPluginBinding,
    private val postMessage: (EspBlufiData) -> Unit,
) {
    private val activity get() = activityPluginBinding.activity

    private val bluetoothManager by lazy {
        ContextCompat.getSystemService(activity, BluetoothManager::class.java)!!
    }

    private val deviceMap: MutableMap<String, ScanResult> = mutableMapOf()
    private var scanCallback: CustomScanCallback? = null

    private var blufiClient: BlufiClient? = null

    private val gattCallback = CustomGattCallback(postMessage)
    private val blufiCallback = CustomBlufiCallback(postMessage)

    fun getPlatformVersion(result: MethodChannel.Result) {
        result.success("Android " + Build.VERSION.RELEASE)
    }

    fun startScan(
        filter: String?,
        result: MethodChannel.Result,
    ) {
        val permissions = getPermissionsList(activity)
        if (permissions.isEmpty()) {
            startScanInternal(
                filter = filter,
                result = result,
            )
        } else {
            ActivityCompat.requestPermissions(
                activity,
                permissions.toTypedArray(),
                REQUEST_FINE_LOCATION_PERMISSIONS,
            )
            result.success(null)
        }
    }

    private fun startScanInternal(
        filter: String?,
        result: MethodChannel.Result,
    ) {
        val adapter = bluetoothManager.adapter
        val scanner = adapter.bluetoothLeScanner

        if (!adapter.isEnabled || scanner == null) {
            result.error(
                "-1",
                "Adapter is not enabled or scanner == null",
                null,
            )
            return
        }

        deviceMap.clear()

        scanner.startScan(
            null,
            ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                .build(),
            CustomScanCallback(
                blufiFilter = filter,
                onAddDevice = { scanResult ->
                    deviceMap[scanResult.device.address] = scanResult
                    postMessage(EspBlufiData.Device(scanResult))
                }
            ).also {
                scanCallback = it
            },
        )
        result.success(true)
    }

    fun stopScan(result: MethodChannel.Result) {
        val adapter = bluetoothManager.adapter
        val scanner = adapter.bluetoothLeScanner
        if (!adapter.isEnabled || scanner == null) {
            result.error(
                "-1",
                "Adapter is not enabled or scanner == null",
                null,
            )
            return
        }
        if (scanCallback == null) {
            result.success(false)
        } else {
            scanner.stopScan(scanCallback)
            deviceMap.clear()
            result.success(true)
        }
    }

    fun connect(deviceId: String?, result: MethodChannel.Result) {
        if (deviceId.isNullOrEmpty() || !deviceMap.containsKey(deviceId)) {
            result.success(false)
        } else {
            connectInternal(deviceMap[deviceId]!!.device)
            result.success(true)
        }
    }

    private fun connectInternal(device: BluetoothDevice) {
        blufiClient?.close()

        BlufiClient(activity.applicationContext, device).apply {
            setGattCallback(gattCallback)
            setBlufiCallback(blufiCallback)
            setGattWriteTimeout(BlufiConstants.GATT_WRITE_TIMEOUT)
        }.also {
            blufiClient = it
        }.connect()
    }

    fun requestCloseConnection(result: MethodChannel.Result) {
        blufiClient?.let {
            it.requestCloseConnection()
            result.success(true)
        } ?: run {
            result.success(false)
        }
    }

    fun requestDeviceWifiScan(result: MethodChannel.Result) {
        blufiClient?.let {
            it.requestDeviceWifiScan()
            result.success(true)
        } ?: run {
            result.success(false)
        }
    }

    fun configure(
        username: String?,
        password: String?,
        result: MethodChannel.Result,
    ) {
        if (username.isNullOrEmpty() || password.isNullOrEmpty()) {
            result.success(false)
            return
        }
        blufiClient?.let {
            it.configure(
                BlufiConfigureParams().apply {
                    opMode = 1
                    staSSIDBytes = username.toByteArray()
                    staPassword = password
                }
            )
            result.success(true)
        } ?: run {
            result.success(false)
        }
    }

    fun getAllPairedDevice() {

    }

    fun requestDeviceStatus() {
        blufiClient?.let {

        }
    }

    fun sendCustomData(data: String?, result: MethodChannel.Result) {
        if (data.isNullOrEmpty()) {
            result.success(false)
            return
        }
        blufiClient?.let {
            it.postCustomData(data.toByteArray())
            result.success(true)
        } ?: run {
            result.success(false)
        }
    }

    private class CustomScanCallback(
        private val blufiFilter: String?,
        private val onAddDevice: (ScanResult) -> Unit,
    ) : android.bluetooth.le.ScanCallback() {

        override fun onBatchScanResults(results: MutableList<ScanResult>?) {
            super.onBatchScanResults(results)
            results?.indices?.forEach { onLeScan(results[it]) }
        }

        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            super.onScanResult(callbackType, result)
            result?.let { onLeScan(it) }
        }

        private fun onLeScan(scanResult: ScanResult) {
            val name = scanResult.device.name
            if (!blufiFilter.isNullOrEmpty()) {
                if (name == null || !name.startsWith(blufiFilter)) {
                    return
                }
            }
            onAddDevice(scanResult)
        }
    }

    private class CustomGattCallback(
        private val postMessage: (EspBlufiData) -> Unit,
    ) : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                when (newState) {
                    BluetoothProfile.STATE_DISCONNECTED -> {
                        gatt.close()
                    }
                }
            } else {
                gatt.close()
            }
            postMessage(
                EspBlufiData.ConnectionStateChange(
                    address = gatt.device.address,
                    status = status,
                    state = newState,
                )
            )
        }

        override fun onMtuChanged(gatt: BluetoothGatt, mtu: Int, status: Int) {
            postMessage(
                EspBlufiData.MtuChange(
                    address = gatt.device.address,
                    status = status,
                    mtu = mtu,
                )
            )
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            if (status != BluetoothGatt.GATT_SUCCESS) {
                gatt.disconnect()
//                updateMessage(
//                    String.format(
//                        Locale.ENGLISH,
//                        "Discover services error status %d",
//                        status
//                    ), false
//                )
            }
        }

        override fun onDescriptorWrite(
            gatt: BluetoothGatt,
            descriptor: BluetoothGattDescriptor,
            status: Int,
        ) {
            if (descriptor.uuid == BlufiParameter.UUID_NOTIFICATION_DESCRIPTOR &&
                descriptor.characteristic.uuid == BlufiParameter.UUID_NOTIFICATION_CHARACTERISTIC
            ) {
                postMessage(
                    EspBlufiData.SetNotification(
                        address = gatt.device.address,
                        status = status,
                    )
                )
            }
        }

        override fun onCharacteristicWrite(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic?,
            status: Int,
        ) {
            if (status != BluetoothGatt.GATT_SUCCESS) {
                gatt.disconnect()
//                updateMessage(
//                    String.format(Locale.ENGLISH, "WriteChar error status %d", status),
//                    false
//                )
            }
        }
    }

    private class CustomBlufiCallback(
        private val postMessage: (EspBlufiData) -> Unit,
    ) : BlufiCallback() {
        override fun onGattPrepared(
            client: BlufiClient,
            gatt: BluetoothGatt,
            service: BluetoothGattService?,
            writeChar: BluetoothGattCharacteristic?,
            notifyChar: BluetoothGattCharacteristic?,
        ) {
            if (service == null || writeChar == null || notifyChar == null) {
                gatt.disconnect()
                postMessage(
                    EspBlufiData.BlufiGattPrepared(
                        address = gatt.device.address,
                        hasService = service != null,
                        hasWriteChar = writeChar != null,
                        hasNotifyChar = notifyChar != null,
                        requestMtu = false,
                        mtu = 0,
                    )
                )
                return
            }
            val mtu = BlufiConstants.DEFAULT_MTU_LENGTH
            val requestMtu = gatt.requestMtu(mtu)
            postMessage(
                EspBlufiData.BlufiGattPrepared(
                    address = gatt.device.address,
                    hasService = true,
                    hasWriteChar = true,
                    hasNotifyChar = true,
                    requestMtu = requestMtu,
                    mtu = mtu,
                )
            )
        }

        override fun onNegotiateSecurityResult(client: BlufiClient, status: Int) {
            postMessage(
                EspBlufiData.BlufiNegotiateSecurityResult(
                    status = status,
                )
            )
        }

        override fun onPostConfigureParams(client: BlufiClient, status: Int) {
            postMessage(
                EspBlufiData.BlufiPostConfigureParams(
                    status = status,
                )
            )
        }

        override fun onDeviceStatusResponse(
            client: BlufiClient,
            status: Int,
            response: BlufiStatusResponse,
        ) {
            postMessage(
                EspBlufiData.BlufiDeviceStatusResponse(
                    status = status,
                    statusMessage = response.generateValidInfo(),
                )
            )
        }

        override fun onDeviceScanResult(
            client: BlufiClient,
            status: Int,
            results: List<BlufiScanResult>,
        ) {
            postMessage(
                EspBlufiData.BlufiScanResult(
                    status = status,
                    results = results,
                )
            )
        }

        override fun onDeviceVersionResponse(
            client: BlufiClient,
            status: Int,
            response: BlufiVersionResponse,
        ) {
            postMessage(
                EspBlufiData.BlufiDeviceVersion(
                    status = status,
                    version = if (status == STATUS_SUCCESS) response.versionString else "",
                )
            )
        }

        override fun onPostCustomDataResult(client: BlufiClient, status: Int, data: ByteArray) {
            postMessage(
                EspBlufiData.BlufiPostCustomDataResult(
                    data = String(data),
                    status = status,
                )
            )
        }

        override fun onReceiveCustomData(client: BlufiClient, status: Int, data: ByteArray) {
            postMessage(
                EspBlufiData.BlufiReceiveCustomData(
                    status = status,
                    data = if (status == STATUS_SUCCESS) String(data) else "",
                )
            )
        }

        override fun onError(client: BlufiClient, errCode: Int) {
            postMessage(
                EspBlufiData.BlufiError(
                    errCode = errCode,
                )
            )
        }
    }

    companion object {
        private const val REQUEST_FINE_LOCATION_PERMISSIONS = 1452

        private fun getPermissionsList(context: Context): List<String> {
            return buildList {
                if (!context.hasPermission(Manifest.permission.ACCESS_FINE_LOCATION)) {
                    add(Manifest.permission.ACCESS_FINE_LOCATION)
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    if (!context.hasPermission(Manifest.permission.BLUETOOTH_SCAN)) {
                        add(Manifest.permission.BLUETOOTH_SCAN)
                    }
                    if (!context.hasPermission(Manifest.permission.BLUETOOTH_CONNECT)) {
                        add(Manifest.permission.BLUETOOTH_CONNECT)
                    }
                }
            }
        }
    }
}

private fun Context.hasPermission(permission: String): Boolean {
    return ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
}