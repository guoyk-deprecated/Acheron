//
//  ACCache.swift
//  Acheron-Demo
//
//  Created by Yanke Guo on 14/11/8.
//  Copyright (c) 2014年 Yanke Guo. All rights reserved.
//

import UIKit

typealias ACCacheBlock        = (cache: ACCache) -> Void
typealias ACCacheObjectBlock  = (cache: ACCache, key: String, object: AnyObject) -> Void

class ACCache: NSObject {
  
  var name  : String = ""
  
  var queue : dispatch_queue_t?
  
  var diskByteCount : UInt  = 0
  
  var diskCache : ACDiskCache?
  
  var memoryCache : ACMemoryCache?
  
  class func sharedCache() -> ACCache {
    fatalError("Not finished")
  }
  
  init(name: String) {
    fatalError("Not finished")
  }
  
  init(name: String, rootPath: String) {
    fatalError("Not finished")
  }
  
  //  MARK: - Async methods
  
  func objectForKey(key: String, block: ACCacheObjectBlock) {
    fatalError("Not finished")
  }
  
  func setObject(object: NSCoding, forKey key: String, block: ACCacheObjectBlock) {
    fatalError("Not finished")
  }
  
  func removeObjectForKey(key: String, block: ACCacheObjectBlock) {
    fatalError("Not finished")
  }
  
  func trimToDate(date: NSDate, block: ACCacheBlock) {
    fatalError("Not finished")
  }
  
  func removeAllObjects(block: ACCacheBlock) {
    fatalError("Not finished")
  }
  
  //  MARK: - Sync Methods
  
  func objectForKey(key: String) -> AnyObject {
    fatalError("Not finished")
  }
  
  func setObject(object: NSCoding, forKey key: String) {
    fatalError("Not finished")
  }
  
  func removeObjectForKey(key: String) {
  }
  
  func trimToDate(date: NSDate) {
  }
  
  func removeAllObjects() {
  }
  
  // MARK: - Subscript
  
  subscript(key: String) -> AnyObject {
    get {
      return self.objectForKey(key)
    }
    set(newValue) {
      self.setObject(newValue as NSCoding, forKey: key)
    }
  }
  
}