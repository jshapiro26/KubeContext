//
//  StatusMenuController.swift
//  KubeContext
//
//  Created by Jeremy Shapiro on 2/19/18.
//  Copyright © 2018 Jeremy Shapiro. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
  
  // @IBOutlet weak var statusMenu: NSMenu!
  let statusMenu = NSMenu()
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  
  func constructMenu() {
    // Set Icon
    let icon = NSImage(named: NSImage.Name(rawValue: "statusIcon"))
    icon?.isTemplate = false // "true" is best for dark mode
    statusItem.image = icon
    // Build current context item
    let menuItem = NSMenuItem()
    menuItem.title = "Current Context: " + currentContext()
    menuItem.action = nil
    statusMenu.addItem(menuItem)
    // Build list of remaining contexts
    statusMenu.addItem(NSMenuItem.separator())
    // Call function to list contexts and save in dictionary
    let everyContext = allContexts()
    // Iterate through contexts and generate menuItems
    for context in everyContext {
      let contextMenuItem = NSMenuItem(title: String(describing: context), action: #selector(StatusMenuController.setContext(_:)), keyEquivalent: "")
      contextMenuItem.target = self
      statusMenu.addItem(contextMenuItem)
    }
    // Add Separater after iterator
    statusMenu.addItem(NSMenuItem.separator())
    // Create Quit menuItem
    statusMenu.addItem(NSMenuItem(title: "Quit KubeContext", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    // Write menu
    statusItem.menu = statusMenu
  }
  
  @objc func setContext(_ sender: NSMenuItem) {
    let kubeConfig = setKubeConfig()
    let savedContext = "current-context: " + sender.title
    let setContext = "current-context: " + currentContext()
    let updatedConfig = kubeConfig!.1.replacingOccurrences(of: setContext, with: savedContext)
    try! updatedConfig.write(to: kubeConfig!.2, atomically: false, encoding: String.Encoding.utf8)
    statusMenu.removeAllItems()
    constructMenu()
  }
  
  func currentContext() -> String {
    let kubeConfigSplit = setKubeConfig()!.0
    for line in kubeConfigSplit {
      if let range = line.range(of:"current-context: ") {
        let setContext = line[range.upperBound...]
        return String(setContext)
      }
    }
    return "String not Set"
  }
  
  func allContexts() -> Array<Any> {
    let kubeConfigSplit = setKubeConfig()!.0
    // Initialize array
    var everyContext = [String]()
    
    for (index, value) in kubeConfigSplit.enumerated() {
      if value.range(of:"- context:") != nil {
        let contextLine = index + 3
        let contextValue = kubeConfigSplit[contextLine]
        if let range = contextValue.range(of: "name: ") {
          let aContext = contextValue[range.upperBound...]
          everyContext.append(String(aContext))
        }
      }
    }
    return(everyContext)
  }
  
  func setKubeConfig() -> ([String], String, URL)? {
    let documentDirectory = FileManager.default.homeDirectoryForCurrentUser
    let fileURL = documentDirectory.appendingPathComponent(".kube/config")
    let config = try! String(contentsOf: fileURL)
    let delimiter = "\n"
    let splitConfig = config.components(separatedBy: delimiter)
    return (splitConfig, config, fileURL)
  }
  
  override func awakeFromNib() {
    constructMenu()
  }
}

