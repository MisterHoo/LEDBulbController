//
//  LEDAttribute.swift
//  ColorLampController
//
//  Created by Yosua Antonio Raphael Ekowidjaja on 26/08/21.
//

import Foundation

class LEDAttribute {
	
	var isOn: Bool
	
	init(data: Data) {
		if data.count > 2 {
			isOn = data[2] == 35
		} else {
			isOn = false
		}
		
	}
}
