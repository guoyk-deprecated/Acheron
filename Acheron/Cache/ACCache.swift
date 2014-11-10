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

let ACCachePrefix     = "io.yanke.accache"
let ACCacheSharedName = "ACCacheShared"

var _sharedACCache : ACCache? = nil

class ACCache {
  
  var name  : String
  var queue : dispatch_queue_t
  var diskByteCount : UInt  = 0
  var diskCache : ACDiskCache
  var memoryCache : ACMemoryCache
  
  class func sharedCache() -> ACCache {
    if _sharedACCache == nil {
      _sharedACCache = ACCache(name: ACCacheSharedName)
    }
    return _sharedACCache!
  }
  
  convenience init() {
    self.init(name: ACCacheSharedName)
  }
  
  convenience init(name: String) {
   let defaultRootPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)![0] as String
    self.init(name: name, rootPath: defaultRootPath)
  }
  
  init(name: String, rootPath: String) {
    self.name = name
    // !!CHANGE
    let queueName : NSString = "\(ACCachePrefix).\(name)"
    self.queue = dispatch_queue_create(queueName.UTF8String, DISPATCH_QUEUE_CONCURRENT)
    self.diskCache = ACDiskCache(name: self.name, rootPath: rootPath)
    self.memoryCache = ACMemoryCache()
  }
  
  //  MARK: - Async methods
  
  func objectForKey(key: String, block: ACCacheObjectBlock) {
    dispatch_async(self.queue, { [weak self] () -> Void in
      if self == nil { return }
      self?.memoryCache.objectForKey(key, block: { [weak self] (cache, key, object) -> Void in
        if self == nil { return }
        
        if object != nil {
          
          self?.diskCache.fileURLForKey(key, block: { (_,_,_,_) -> Void in return })
          
          dispatch_async(self?.queue, { [weak self] () -> Void in
            if self == nil { return }
            block(cache: self!, key: key, object: object!)
          })
          
        } else {
          self?.diskCache.objectForKey(key, block: { [weak self] (cache, key, object, fileURL) -> Void in
            if self == nil { return }
            self?.memoryCache.setObject(object, forKey: key, block: nil)
            dispatch_async(self?.queue, { [weak self] () -> Void in
              if self == nil { return }
              block(cache: self!, key: key, object: object)
            })
          })
        }
      })
    })
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