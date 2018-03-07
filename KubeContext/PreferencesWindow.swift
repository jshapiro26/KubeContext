//
//  PreferencesWindow.swift
//  KubeContext
//
//  Created by Jeremy Shapiro on 3/6/18.
//  Copyright © 2018 Jeremy Shapiro. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
  func preferencesDidUpdate()
}

var delegate: PreferencesWindowDelegate?

class PreferencesWindow: NSWindowController, NSWindowDelegate {
  
  @IBOutlet weak var showContextInMenuBar: NSButton!
  
  override var windowNibName: NSNib.Name? {
    return NSNib.Name("PreferencesWindow")
  }

  func preferenceStateValue(_ action: String = "read", _ state: Bool = true) -> Bool? {
    // set variables to read/write files
    let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
    let preferencesDirURL = homeDirectory.appendingPathComponent(".config/kubecontext")
    let preferencesFileURL = preferencesDirURL.appendingPathComponent("config")
    // set variables to check if config directory exists
    let fileManager = FileManager.default
    var isDir : ObjCBool = true
    // check if directory exists, if not create it and a default config file
    if fileManager.fileExists(atPath: String(describing: preferencesDirURL.path), isDirectory:&isDir) != true {
      try! fileManager.createDirectory(atPath: String(describing: preferencesDirURL.path), withIntermediateDirectories: true, attributes: nil)
      let data = ("contextInMenu=true").data(using: String.Encoding.utf8)
      fileManager.createFile(atPath: String(describing: preferencesFileURL.path), contents: data, attributes: nil)
    }
    if action == "read" {
      let config = try! String(contentsOf: preferencesFileURL)
      if config.contains("contextInMenu=true") {
        return true
      } else {
        return false
      }
    }
    if action == "write" {
      let contents = "contextInMenu=" + String(describing: state)
      try! contents.write(to: preferencesFileURL, atomically: false, encoding: String.Encoding.utf8)
      return true
    }
    // This should never fire because of default parameters
    return true
  }

  override func windowDidLoad() {
    if preferenceStateValue("read", true)! {
      showContextInMenuBar.state = NSControl.StateValue.on
    } else {
      showContextInMenuBar.state = NSControl.StateValue.off
    }
    super.windowDidLoad()
    self.window?.center()
    self.window?.makeKeyAndOrderFront(nil)
    self.window?.level = .floating
    NSApp.activate(ignoringOtherApps: true)
  }

  func windowWillClose(_ notification: Notification) {
    if showContextInMenuBar.state.rawValue == 0 {
      preferenceStateValue("write", false)
    } else {
      if showContextInMenuBar.state.rawValue == 1 {
        preferenceStateValue("write", true)
      }
    }
    delegate?.preferencesDidUpdate()
  }
  
}
