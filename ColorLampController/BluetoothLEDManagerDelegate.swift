//
//  BluetoothLEDManagerDelegate.swift
//  ColorLampController
//
//  Created by Yosua Antonio Raphael Ekowidjaja on 26/08/21.
//

import Foundation
import CoreBluetooth

protocol BluetoothLEDManagerDelegate {
	
	func bluetoothManager(_ manager: BluetoothLEDManager, didChange state: CBManagerState)
	func bluetoothManager(_ manager: BluetoothLEDManager, didDiscover peripherals: [CBPeripheral])
	func peripheral(_ manager: BluetoothLEDManager, didConnect peripheral: CBPeripheral)
	func peripheral(_ manager: BluetoothLEDManager, didDisconnect peripheral: CBPeripheral)
	func peripheral(_ manager: BluetoothLEDManager, didChange attribute: LEDAttribute)
}
