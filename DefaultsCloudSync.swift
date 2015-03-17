//
//  DefaultsCloudSync.swift
//
//  Created by Richard Rubin on 3/17/15.
//  Copyright (c) 2015 Richard Rubin. All rights reserved.
//
//
// Synchronizes NSUserDefaults with iCloud
// Just call DefaultsCloudSync.start() and you're done.
//

import UIKit

class DefaultsCloudSync: NSObject {
   
    class func start() {

        //Note: NSUbiquitousKeyValueStoreDidChangeExternallyNotification is sent only upon a change received from iCloud, not when your app (i.e., the same instance) sets a value.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUserDefaultsFromiCloud:", name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateiCloudFromUserDefaults:", name: NSUserDefaultsDidChangeNotification, object: nil)
        
        println("Enabled automatic synchronization of NSUserDefaults and iCloud.")
    }
    
    
    class func updateUserDefaultsFromiCloud(notification:NSNotification?) {
        
        //prevent loop of notifications by removing our observer before we update NSUserDefaults
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil);

        let iCloudDictionary = NSUbiquitousKeyValueStore.defaultStore().dictionaryRepresentation
        let userDefaults     = NSUserDefaults.standardUserDefaults()
        
        for (key, obj) in iCloudDictionary {
            userDefaults.setObject(obj, forKey: key as String)
        }
                
        userDefaults.synchronize()
        
        // re-enable NSUserDefaultsDidChangeNotification notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateiCloudFromUserDefaults:", name: NSUserDefaultsDidChangeNotification, object: nil)
        
        println("Updated NSUserDefaults from iCloud")
    }

    
    class func updateiCloudFromUserDefaults(notification:NSNotification?) {
        
        let defaultsDictionary = NSUserDefaults.standardUserDefaults().dictionaryRepresentation()
        let cloudStore         = NSUbiquitousKeyValueStore.defaultStore()
        
        for (key, obj) in defaultsDictionary {
               cloudStore.setObject(obj, forKey: key as String)
        }
        
        // let iCloud know that new or updated keys, values are ready to be uploaded
        cloudStore.synchronize()
        
        println("Notified iCloud of local updates")
    }

    
    deinit {

        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: nil);

    }
}
