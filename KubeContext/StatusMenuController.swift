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
    let savedContext = "current-context: " + sender.title
    let documentDirectory = FileManager.default.homeDirectoryForCurrentUser
    let fileURL = documentDirectory.appendingPathComponent(".kube/config")
    let config = try! String(contentsOf: fileURL)
    let setContext = "current-context: " + currentContext()
    let updatedConfig = config.replacingOccurrences(of: setContext, with: savedContext)
    try! updatedConfig.write(to: fileURL, atomically: false, encoding: String.Encoding.utf8)
    statusMenu.removeAllItems()
    constructMenu()
  }
  
  func currentContext() -> String {
    let documentDirectory = FileManager.default.homeDirectoryForCurrentUser
    let fileURL = documentDirectory.appendingPathComponent(".kube/config")
    let config = try! String(contentsOf: fileURL)
    
    let delimiter = "\n"
    let splitConfig = config.components(separatedBy: delimiter)
    
    for line in splitConfig {
      if let range = line.range(of:"current-context: ") {
        let setContext = line[range.upperBound...]
        return String(setContext)
        break
      }
    }
    return "String not Set"
  }
  
  func allContexts() -> Array<Any> {
    // Initialize array
    var everyContext = [String]()
    
    let documentDirectory = FileManager.default.homeDirectoryForCurrentUser
    let fileURL = documentDirectory.appendingPathComponent(".kube/config")
    let config = try! String(contentsOf: fileURL)
    
    let delimiter = "\n"
    let splitConfig = config.components(separatedBy: delimiter)
    
    for (index, value) in splitConfig.enumerated() {
      if value.range(of:"- context:") != nil {
        let contextLine = index + 3
        let contextValue = splitConfig[contextLine]
        if let range = contextValue.range(of: "name: ") {
          let aContext = contextValue[range.upperBound...]
          everyContext.append(String(aContext))
        }
      }
    }
    return(everyContext)
  }
  
  override func awakeFromNib() {
    constructMenu()
  }
}

