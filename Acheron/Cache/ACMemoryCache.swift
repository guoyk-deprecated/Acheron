//
//  ACMemoryCache.swift
//  Acheron-Demo
//
//  Created by Yanke Guo on 14/11/8.
//  Copyright (c) 2014年 Yanke Guo. All rights reserved.
//

import UIKit

typealias ACMemoryCacheBlock        = (cache: ACMemoryCache) -> Void
typealias ACMemoryCacheObjectBlock  = (cache: ACMemoryCache, key: String, object: AnyObject?) -> Void

class ACMemoryCache: NSObject {
  
  var queue : dispatch_queue_t?
  
  var totoalCost : UInt?
  
  var costLimit : UInt?
  
  var ageLimit : NSTimeInterval?
  
  var removeAllObjectsOnMemoryWarning : Bool = false
  
  var removeAllObjectsOnEnteringBackground : Bool = false
  
  var willAddObjectBlock : ACMemoryCacheObjectBlock?
  
  var willRemoveObjectBlock : ACMemoryCacheObjectBlock?
  
  var willRemoveAllObjectsBlock : ACMemoryCacheBlock?
  
  var didAddObjectBlock : ACMemoryCacheObjectBlock?
  
  var didRemoveObjectBlock : ACMemoryCacheObjectBlock?
  
  var didRemoveAllObjectsBlock : ACMemoryCacheBlock?
  
  var didReceiveMemoryWarningBlock : ACMemoryCacheBlock?
  
  var didEnterBackgroundBlock : ACMemoryCacheBlock?
  
  class func sharedCache() -> ACMemoryCache {
    fatalError("Not finished")
  }
  
  func objectForKey(key: String, block: ACMemoryCacheObjectBlock) {
  }
  
  func setObject(object: AnyObject, forKey key: String, block: ACMemoryCacheObjectBlock?) {
  }
  
  func setObject(object: AnyObject, forKey key: String, withCost cost: UInt, block: ACMemoryCacheObjectBlock) {
  }
  
  func removeObjectForKey(key: String, block: ACMemoryCacheObjectBlock) {
  }
  
  func trimToDate(date: NSDate, block: ACMemoryCacheBlock) {
  }
  
  func trimToCost(cost: UInt, block: ACMemoryCacheBlock) {
  }
  
  func trimToCostByDate(cost: UInt, block: ACMemoryCacheBlock) {
  }
  
  func removeAllObjects(block: ACMemoryCacheBlock) {
  }
  
  func enumerateObjectsWithBlock(block: ACMemoryCacheObjectBlock, completionBlock: ACMemoryCacheBlock) {
  }
  
  //  MARK: - Sync Methods
  
  func objectForKey(key: String) -> AnyObject {
    fatalError("Not finished")
  }
  
  func setObject(object: AnyObject, forKey key: String) {
  }
  
  func setObject(object: AnyObject, forKey key: String, withCost cost: UInt) {
  }
  
  func removeObjectForKey(key: String) {
  }
  
  func trimToDate(date: NSDate) {
  }
  
  func trimToCost(cost: UInt) {
  }
  
  func trimToCostByDate(cost: UInt) {
  }
  
  func removeAllObjects() {
  }
  
  func enumerateObjectsWithBlock(block: ACMemoryCacheObjectBlock) {
  }
   
}