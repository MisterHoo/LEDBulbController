//
//  ViewController.swift
//  ColorLampController
//
//  Created by Yosua Antonio Raphael Ekowidjaja on 25/08/21.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
	
	@IBOutlet weak var powerSwitch: UISwitch!
	@IBOutlet weak var whiteSwitch: UISwitch!
	
	@IBOutlet weak var tfDevice: UITextField!
	
	@IBOutlet weak var tfRed: UITextField!
	@IBOutlet weak var redSlider: UISlider!
	@IBOutlet weak var tfGreen: UITextField!
	@IBOutlet weak var greenSlider: UISlider!
	@IBOutlet weak var tfBlue: UITextField!
	@IBOutlet weak var blueSlider: UISlider!
	
	@IBOutlet weak var tfIntensity: UITextField!
	@IBOutlet weak var intensitySlider: UISlider!
	
	@IBOutlet weak var loadingView: UIView!
	
	private var red: Float = 0 {
		didSet {
			isWhite = false
			updateProperties()
		}
	}
	
	private var green: Float = 0 {
		didSet {
			isWhite = false
			updateProperties()
		}
	}
	
	private var blue: Float = 0 {
		didSet {
			isWhite = false
			updateProperties()
		}
	}
	
	private var intensity: Float = 100 {
		didSet {
			updateProperties()
		}
	}
	
	private var isOn: Bool = false {
		didSet {
			powerSwitch.setOn(isOn, animated: true)
		}
	}
	
	private var isWhite: Bool = false {
		didSet {
			whiteSwitch.setOn(isWhite, animated: true)
			
			if isWhite {
				DispatchQueue.main.async { [weak self] in
					self?.view.backgroundColor = UIColor.white
				}
			}
		}
	}
	
	private let manager: BluetoothLEDManager = BluetoothLEDManager()
	
	private var peripherals: [CBPeripheral] = [] {
		didSet{
			picker.reloadAllComponents()
		}
	}
	
	private let picker = UIPickerView()
	
	@IBAction func tfRedValueChanged(_ sender: Any) {
		guard let text = tfRed.text, var value = Float(text) else {
			tfRed.text = "0"
			return
		}
		
		value = max(255, value)
		tfRed.text = String(format: "%.0f", value)
		redSlider.value = value
		red = value
	}
	
	@IBAction func tfGreenValueChanged(_ sender: Any) {
		guard let text = tfGreen.text, var value = Float(text) else {
			tfGreen.text = "0"
			return
		}
		
		value = min(255, value)
		tfGreen.text = String(format: "%.0f", value)
		greenSlider.value = value
		green = value
	}
	
	@IBAction func tfBlueValueChanged(_ sender: Any) {
		guard let text = tfBlue.text, var value = Float(text) else {
			tfBlue.text = "0"
			return
		}
		
		value = min(255, value)
		tfBlue.text = String(format: "%.0f", value)
		blueSlider.value = value
		blue = value
	}
	
	@IBAction func tfIntensityValueChanged(_ sender: Any) {
		guard let text = tfIntensity.text, var value = Float(text) else {
			tfIntensity.text = "0"
			return
		}
		
		value = min(255, value)
		tfIntensity.text = String(format: "%.0f", value)
		intensitySlider.value = value
		intensity = value
	}
	
	@IBAction func redSliderChanged(_ sender: Any) {
		let value = redSlider.value
		tfRed.text = String(format: "%.0f", value)
		red = value
	}
	
	@IBAction func greenSliderChanged(_ sender: Any) {
		let value = greenSlider.value
		tfGreen.text = String(format: "%.0f", value)
		green = value
	}
	
	@IBAction func blueSliderChanged(_ sender: Any) {
		let value = blueSlider.value
		tfBlue.text = String(format: "%.0f", value)
		blue = value
	}
	
	@IBAction func intensitySliderChanged(_ sender: Any) {
		let value = intensitySlider.value
		tfIntensity.text = String(format: "%.0f", value)
		intensity = value
	}
	
	@IBAction func powerSwitch(_ sender: Any) {
		manager.switchPower()
	}
	
	@IBAction func setToWhite(_ sender: Any) {
		isWhite = whiteSwitch.isOn
		
		if isWhite {
			manager.setToWhite(intensity: intensity)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			// Always adopt a light interface style.
			overrideUserInterfaceStyle = .light
		}
		
		setupManager()
		setupPicker()
	}
	
	private func setupManager() {
		manager.delegate = self
	}
	
	private func setupPicker() {
		picker.dataSource = self
		picker.delegate = self
		
		tfDevice.inputView = picker
		tfDevice.inputAccessoryView = createInputToolbar()
	}
	
	private func setupOtherTextField() {
		tfRed.inputAccessoryView = createInputToolbar()
		tfGreen.inputAccessoryView = createInputToolbar()
		tfBlue.inputAccessoryView = createInputToolbar()
		tfIntensity.inputAccessoryView = createInputToolbar()
	}
	
	private func createInputToolbar() -> UIToolbar {
		let toolbar: UIToolbar = UIToolbar()
		let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditing))
		
		toolbar.items = [flexSpace, doneButton]
		toolbar.sizeToFit()
		
		return toolbar
	}
	
	@objc private func doneEditing() {
		self.view.endEditing(true)
	}
	
	private func updateProperties() {
		setBackgroundColor()
		
		if isWhite {
			manager.setToWhite(intensity: intensity)
		} else {
			manager.setToColor(red: red, green: green, blue: blue)
		}
	}
	
	private func setBackgroundColor() {
		var color = UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: CGFloat(intensity/255.0))
		
		if isWhite {
			color = UIColor(white: 1.0, alpha: CGFloat(intensity/255.0))
		}
		
		DispatchQueue.main.async { [weak self] in
			self?.view.backgroundColor = color
		}
	}
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return peripherals.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return peripherals[row].name
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		guard peripherals.count > row else {
			return
		}
		
		let peripheral = peripherals[row]
		let name = peripheral.name
		tfDevice.text = name
		
		loadingView.isHidden = false
		manager.connect(peripheral: peripheral)
	}
}

extension ViewController: BluetoothLEDManagerDelegate {
	func bluetoothManager(_ manager: BluetoothLEDManager, didChange state: CBManagerState) {
		if state == .poweredOn {
			loadingView.isHidden = false
		} else {
			loadingView.isHidden = false
		}
	}
	
	func bluetoothManager(_ manager: BluetoothLEDManager, didDiscover peripherals: [CBPeripheral]) {
		loadingView.isHidden = true
		self.peripherals = peripherals
	}
	
	func peripheral(_ manager: BluetoothLEDManager, didConnect peripheral: CBPeripheral) {
		loadingView.isHidden = true
	}
	
	func peripheral(_ manager: BluetoothLEDManager, didDisconnect peripheral: CBPeripheral) {
		
	}
	
	func peripheral(_ manager: BluetoothLEDManager, didChange attribute: LEDAttribute) {
		isOn = attribute.isOn
	}
}
