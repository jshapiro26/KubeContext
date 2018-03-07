//
//  StatusMenuController.swift
//  KubeContext
//
//  Created by Jeremy Shapiro on 2/19/18.
//  Copyright © 2018 Jeremy Shapiro. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, PreferencesWindowDelegate {
  
  let statusMenu = NSMenu()
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  var preferencesWindow: PreferencesWindow!
  
  func constructMenu() {
    // Set Icon
    let icon = NSImage(named: NSImage.Name(rawValue: "statusIcon"))
    icon?.isTemplate = false // "true" is best for dark mode
    statusItem.image = icon
    // Build refresh item
    let refreshItem = NSMenuItem(title: "Refresh Contexts", action: #selector(StatusMenuController.refreshAll(_:)), keyEquivalent: "r")
    refreshItem.target = self
    statusMenu.addItem(refreshItem)
    statusMenu.addItem(NSMenuItem.separator())
    // Build preferences window
    let preferencesItem = NSMenuItem(title: "Preferences", action: #selector(StatusMenuController.preferencesClicked(_:)), keyEquivalent: "p")
    preferencesItem.target = self
    statusMenu.addItem(preferencesItem)
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
    // Add checkmark next to current context
    indicateCurrentContext()
  }
  
  @objc func refreshAll(_ sender: NSMenuItem?) {
    // Re-contstruct menu; use-case is when you add new contexts
    // and need to make them appear in the menu
    statusMenu.removeAllItems()
    constructMenu()
  }
  
  @objc func indicateCurrentContext() {
    for item in (statusItem.menu?.items)! {
      if item.title == currentContext() {
        item.state = NSControl.StateValue.on
        // Read defaults to determine to show context name in
        // Refactor into function to call and return bool
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
          if key == "showContextInMenuBar" {
            let contextInMenuBarPreference = value as! NSNumber
            if contextInMenuBarPreference == 1 as NSNumber{
              statusItem.title = " " + item.title
            } else {
              statusItem.title = ""
            }
          }
        }
      } else {
        item.state = NSControl.StateValue.off
      }
    }
  }
  
  @objc func setContext(_ sender: NSMenuItem) {
    let kubeConfig = setKubeConfig()
    let savedContext = "current-context: " + sender.title
    let setContext = "current-context: " + currentContext()
    let updatedConfig = kubeConfig!.1.replacingOccurrences(of: setContext, with: savedContext)
    try! updatedConfig.write(to: kubeConfig!.2, atomically: false, encoding: String.Encoding.utf8)
    indicateCurrentContext()
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
  
  @objc func preferencesClicked(_ sender: Any) {
    preferencesWindow.showWindow(nil)
  }
  
  func preferencesDidUpdate() {
    refreshAll(nil)
  }
  
  override func awakeFromNib() {
    preferencesWindow = PreferencesWindow()
    // Sets default of showing context in menu at run
    // Refactor to set config file that stores prefs and read from that
    let defaults = UserDefaults.standard
    if !defaults.dictionaryRepresentation().keys.contains("showContextInMenuBar") {
      defaults.set(1, forKey: "showContextInMenuBar")
    }
    constructMenu()
    // Check and menuitem of current context if changed outside of app (e.g. cli)
    let timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(indicateCurrentContext), userInfo: nil, repeats: true)
    timer.fire()
  }
}

