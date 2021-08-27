//
//  BluetoothLEDManager.swift
//  ColorLampController
//
//  Created by Yosua Antonio Raphael Ekowidjaja on 26/08/21.
//

import Foundation
import CoreBluetooth

class BluetoothLEDManager: NSObject {
	
	//Peripheral Attributes
	var delegate: BluetoothLEDManagerDelegate?
	
	var attribute: LEDAttribute?
	var selectedPeripheral: CBPeripheral?
	
	var peripherals: [CBPeripheral] = [] {
		didSet{
			delegate?.bluetoothManager(self, didDiscover: peripherals)
		}
	}
	
	private let writeCharacteristicIdentifier = "FFD9"
	private var cbManager: CBCentralManager?
	private var writeCharacteristic: CBCharacteristic?
	
	override init() {
		super.init()
		cbManager = CBCentralManager(delegate: self, queue: nil)
	}
	
	func connect(peripheral: CBPeripheral) {
		cbManager?.connect(peripheral, options: nil)
	}
	
	func switchPower() {
		guard let characteristic = writeCharacteristic,
			  let peripheral = self.selectedPeripheral else {
			return
		}
		
		var writeValue: [UInt8] = []
		
		let isOnValue = (attribute?.isOn ?? false)
		
		writeValue.append(204)
		writeValue.append(isOnValue ? 36 : 35)
		writeValue.append(51)
		
		let data = Data(writeValue)
		peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
		attribute?.isOn = !isOnValue
	}
	
	func setToWhite(intensity: Float) {
		guard let characteristic = writeCharacteristic,
			  let peripheral = self.selectedPeripheral else {
			return
		}
		
		var writeValue: [UInt8] = []
		writeValue.append(86)
		writeValue.append(0)
		writeValue.append(0)
		writeValue.append(0)
		writeValue.append(UInt8(intensity))
		writeValue.append(15)
		writeValue.append(170)
		
		let data = Data(writeValue)
		peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
	}
	
	func setToColor(red: Float, green: Float, blue: Float) {
		guard let characteristic = writeCharacteristic,
			  let peripheral = self.selectedPeripheral else {
			return
		}
		
		var writeValue: [UInt8] = []
		writeValue.append(86)
		writeValue.append(UInt8(red))
		writeValue.append(UInt8(green))
		writeValue.append(UInt8(blue))
		writeValue.append(0)
		writeValue.append(240)
		writeValue.append(170)
		
		let data = Data(writeValue)
		peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
	}
	
	private func scanPeripheral() {
		cbManager?.scanForPeripherals(withServices: nil, options: nil)
	}
}

extension BluetoothLEDManager: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		switch central.state {
		case .unknown:
			print("[LOG]: Bluetooth Error Unknown occured")
		case .resetting:
			print("[LOG]: Bluetooth Reset")
		case .unsupported:
			print("[LOG]: Bluetooth Unsupported")
		case .unauthorized:
			print("[LOG]: Bluetooth Unauthorized")
		case .poweredOff:
			print("[LOG]: Bluetooth Turned Off")
		case .poweredOn:
			print("[LOG]: Bluetooth Turned On")
			scanPeripheral()
		default:
			break
		}
		
		delegate?.bluetoothManager(self, didChange: central.state)
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		
		guard peripheral.name == "Triones-FFFF2034B2C4" else {
			return
		}
		
		peripherals.append(peripheral)
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		self.selectedPeripheral = peripheral
		peripheral.delegate = self
		peripheral.discoverServices(nil)
		delegate?.peripheral(self, didConnect: peripheral)
	}
	
	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		delegate?.peripheral(self, didDisconnect: peripheral)
	}
}

extension BluetoothLEDManager: CBPeripheralDelegate {
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		
		print()
		print("Peripheral: \(peripheral)")
		guard let services = peripheral.services else {
			return
		}

		print("Services")

		for service in services {
			print(service)
			peripheral.discoverCharacteristics(nil, for: service)
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		
		guard let characteristics = service.characteristics else {
			return
		}
	
		for characteristic in characteristics {
			print(characteristic)
			if let value = characteristic.value {
				for byte in value {
					print(byte)
				}
				
				let attribute = LEDAttribute(data: value)
				self.attribute = attribute
				delegate?.peripheral(self, didChange: attribute)
				
			} else if characteristic.uuid == CBUUID(string: writeCharacteristicIdentifier) {
				self.writeCharacteristic = characteristic
			}
		}
	}
}
