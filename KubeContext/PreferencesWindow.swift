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

  override func windowDidLoad() {
      super.windowDidLoad()
      self.window?.center()
      self.window?.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
  }

  func windowWillClose(_ notification: Notification) {
    let defaults = UserDefaults.standard
    defaults.set(showContextInMenuBar.state.rawValue, forKey: "showContextInMenuBar")
    delegate?.preferencesDidUpdate()
  }
    
}
