package yu.legend.esp_blufi

import android.bluetooth.le.ScanResult
import org.json.JSONArray
import org.json.JSONObject

sealed interface EspBlufiMessage {
    class Device(
        private val result: ScanResult
    ) : EspBlufiMessage {
        override fun toString(): String {
            return response("ble_scan_result") {
                put("address", result.device.address)
                put("name", result.device.name)
                put("rssi", result.rssi)
            }
        }
    }

    class ConnectionStateChange(
        private val address: String,
        private val status: Int,
        private val state: Int,
    ) : EspBlufiMessage {
        override fun toString(): String {
            return response("ble_gatt_state") {
                put("address", address)
                put("status", status)
                put("state", state)
            }
        }
    }

    class MtuChange(
        private val address: String,
        private val status: Int,
        private val mtu: Int,
    ) : EspBlufiMessage {
        override fun toString(): String {
            return response("ble_mtu_change") {
                put("address", address)
                put("status", status)
                put("mtu", mtu)
            }
        }
    }

    class SetNotification(
        private val address: String,
        private val status: Int,
    ) :EspBlufiMessage {
        override fun toString(): String {
            return response("ble_set_notification") {
                put("address", address)
                put("status", status)
            }
        }
    }

    // Blufi

    class BlufiGattPrepared(
        private val address: String,
        private val hasService: Boolean,
        private val hasWriteChar: Boolean,
        private val hasNotifyChar: Boolean,
        private val requestMtu: Boolean,
        private val mtu: Int,
    ) : EspBlufiMessage {
        override fun toString(): String {
            return response("blufi_gatt_prepared") {
                put("address", address)
                put("hasService", hasService)
                put("hasWriteChar", hasWriteChar)
                put("hasNotifyChar", hasNotifyChar)
                put("requestMtu", requestMtu)
                put("mtu", mtu)
            }
        }
    }

    class BlufiNegotiateSecurityResult(
        private val status: Int,
    ) : EspBlufiMessage {
        override fun toString(): String {
            return response("blufi_negotiate_security_result") {
                put("status", status)
            }
        }
    }

    class BlufiPostConfigureParams(
        private val status: Int
    ) : EspBlufiMessage {
        override fun toString(): String {
            return response("blufi_post_configure_params") {
                put("status", status)
            }
        }
    }

    class BlufiDeviceStatusResponse(
        private val status: Int,
        private val statusMessage: String,
    ) : EspBlufiMessage {
        override fun toString(): String {
            return response("blufi_device_status_response") {
                put("status", status)
                put("statusMessage", statusMessage)
            }
        }
    }

    class BlufiScanResult(
        val status: Int,
        val results: List<blufi.espressif.response.BlufiScanResult>,
    ) : EspBlufiMessage {
        override fun toString(): String {
            return response("blufi_scan_result") {
                put("status", status)
                put("results", JSONArray().apply {
                    results.forEach { result ->
                        put(JSONObject().apply {
                            put("ssid", result.ssid)
                            put("type", result.type)
                            put("rssi", result.rssi)
                        })
                    }
                })
            }
        }
    }

    class BlufiDeviceVersion(
        private val status: Int,
        private val version: String,
    ) : EspBlufiMessage {
        override fun toString(): String {
            return response("blufi_device_version") {
                put("status", status)
                put("version", version)
            }
        }
    }

    class BlufiPostCustomDataResult(
        private val data: String,
        private val status: Int,
    ) : EspBlufiMessage {
        override fun toString(): String {
            return response("blufi_post_custom_data_result") {
                put("data", data)
                put("status", status)
            }
        }
    }

    class BlufiReceiveCustomData(
        private val status: Int,
        private val data: String,
    ) : EspBlufiMessage {
        override fun toString(): String {
            return response("blufi_receive_custom_data") {
                put("status", status)
                put("data", data)
            }
        }
    }

    class BlufiError(
        private val errCode: Int,
    ) : EspBlufiMessage {
        override fun toString(): String {
            return response("blufi_error") {
                put("errCode", errCode)
            }
        }
    }
}

private fun response(key: String, block: JSONObject.() -> Unit): String {
    return JSONObject().apply {
        put("key", key)
        put("value", JSONObject().apply(block))
    }.toString()
}