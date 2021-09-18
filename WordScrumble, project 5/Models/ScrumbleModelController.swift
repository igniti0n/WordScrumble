//
//  ScrumbleModelController.swift
//  WordScrumble, project 5
//
//  Created by Ivan Stajcer on 18.09.2021..
//

import Foundation

class ScrumbleModelController: ObservableObject {
  @Published  var model = ScrumbleModel()
  @Published  var isAlertShown = false
}
