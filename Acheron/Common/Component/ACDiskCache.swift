//
//  ACDiskCache.swift
//  Acheron-Demo
//
//  Created by Yanke Guo on 14/11/8.
//  Copyright (c) 2014年 Yanke Guo. All rights reserved.
//

import UIKit

typealias ACDiskCacheBlock          = (cache: ACDiskCache) -> Void
typealias ACDiskCacheObjectBlock    = (cache: ACDiskCache, key: String, object: NSCoding?, fileURL: NSURL) -> Void

class ACDiskCache: NSObject {
  
  var name  : String = ""
  
  var cacheURL : NSURL?
  
  var byteCount : UInt = 0
  
  var byteLimit : UInt = 0
  
  var ageLimit : NSTimeInterval = 0
  
  var willAddObjectBlock : ACDiskCacheObjectBlock?
  
  var willRemoveObjectBlock : ACDiskCacheObjectBlock?
  
  var willRemoveAllObjectsBlock : ACDiskCacheObjectBlock?
  
  var didAddObjectBlock : ACDiskCacheObjectBlock?
  
  var didRemoveObjectBlock : ACDiskCacheObjectBlock?
  
  var didRemoveAllObjectsBlock : ACDiskCacheObjectBlock?
  
  class func sharedCache() -> ACDiskCache {
    fatalError("Not finished")
  }
  
  class func sharedQueue() -> dispatch_queue_t {
    fatalError("Not finished")
  }
  
  class func emptyTrash() {
  }
  
  init(name: String) {
    fatalError("Not finished")
  }
  
  init(name: String, rootPath: String) {
    fatalError("Not finished")
  }
  
  //  MARK: - Async Methods
  
  func objectForKey(key: String, block: ACDiskCacheObjectBlock) {
  }
  
  func fileURLForKey(key: String, block: ACDiskCacheObjectBlock) {
  }
  
  func setObject(object: NSCoding, forKey key: String, block: ACDiskCacheObjectBlock) {
  }
  
  func removeObjectForKey(key: String, block: ACDiskCacheObjectBlock) {
  }
  
  func trimToDate(date: NSDate, block: ACDiskCacheBlock) {
  }
  
  func trimToSize(size: UInt, block: ACDiskCacheBlock) {
  }
  
  func trimToSizeByDate(date: NSDate, block: ACDiskCacheBlock) {
  }
  
  func removeAllObjects(block: ACDiskCacheBlock) {
  }
  
  func enumerateObjectsWithBlock(block: ACDiskCacheObjectBlock, completionBlock: ACDiskCacheBlock) {
  }
  
  //  MARK: - Sync Methods
  
  func objectForKey(key: String) -> AnyObject {
    fatalError("Not Complete")
  }
  
  func fileURLForKey(key: String) -> NSURL {
    fatalError("Not Complete")
  }
  
  func setObject(object: NSCoding, forKey key: String) {
  }
  
  func removeObjectForKey(key: String) {
  }
  
  func trimToDate(date: NSDate) {
  }
  
  func trimToSize(size: UInt) {
  }
  
  func trimToSizeByDate(size: UInt) {
  }
  
  func removeAllObjects() {
  }
  
  func enumerateObjectsWithBlock(block: ACDiskCacheObjectBlock) {
  }
  
}