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

let ACMemoryCacheEmptyBlock       : ACMemoryCacheBlock        = { _     in return }
let ACMemoryCacheObjectEmptyBlock : ACMemoryCacheObjectBlock  = { _,_,_ in return }

let ACMemoryCachePrefix = "io.yanke.acmemorycache"

var _sharedACMemoryCache : ACMemoryCache? = nil

class ACMemoryCache {
  
  let queue : dispatch_queue_t
  
  let dictionary  = NSMutableDictionary()
  let costs       = NSMutableDictionary()
  let dates       = NSMutableDictionary()
  
  var totoalCost  : UInt = 0
  var costLimit   : UInt  = 0
  var ageLimit    : NSTimeInterval = 0
  
  var removeAllObjectsOnMemoryWarning       : Bool = true
  var removeAllObjectsOnEnteringBackground  : Bool = true
  
  var willAddObjectBlock        : ACMemoryCacheObjectBlock?
  var willRemoveObjectBlock     : ACMemoryCacheObjectBlock?
  var willRemoveAllObjectsBlock : ACMemoryCacheBlock?
  var didAddObjectBlock         : ACMemoryCacheObjectBlock?
  var didRemoveObjectBlock      : ACMemoryCacheObjectBlock?
  var didRemoveAllObjectsBlock  : ACMemoryCacheBlock?
  var didReceiveMemoryWarningBlock  : ACMemoryCacheBlock?
  var didEnterBackgroundBlock       : ACMemoryCacheBlock?
  
  class func sharedCache() -> ACMemoryCache {
    if _sharedACMemoryCache == nil {
      _sharedACMemoryCache = ACMemoryCache()
    }
    return _sharedACMemoryCache!
  }
  
  init() {
    let queueName = "\(ACMemoryCachePrefix).\(CACurrentMediaTime())"
    self.queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT)
    
    //  Notifications
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onNotificationReceived:", name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication())
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onNotificationReceived:", name: UIApplicationDidReceiveMemoryWarningNotification, object: UIApplication.sharedApplication())
  }
  
  func onNotificationReceived(notification: NSNotification) {
    if notification.name == UIApplicationDidReceiveMemoryWarningNotification {
      if self.removeAllObjectsOnMemoryWarning {
        self.removeAllObjects(ACMemoryCacheEmptyBlock)
      }
      dispatch_async(self.queue, { [weak self] () -> Void in
        if self == nil { return }
        self?.didReceiveMemoryWarningBlock?(cache: self!)
      })
    } else if notification.name == UIApplicationDidEnterBackgroundNotification {
      if self.removeAllObjectsOnEnteringBackground {
        self.removeAllObjects(ACMemoryCacheEmptyBlock)
      }
      dispatch_async(self.queue, { [weak self] () -> Void in
        if self == nil { return }
        self?.didEnterBackgroundBlock?(cache: self!)
      })
    }
  }
  
  //  MARK: - Internal Methods
  
  func removeObjectAndExecuteBlocksForKey(key: String) {
    let obj : AnyObject? = self.dictionary.objectForKey(key)
    self.willRemoveObjectBlock?(cache: self, key: key, object: obj)
    if let cost = self.costs.objectForKey(key) as NSNumber? {
      self.totoalCost -= cost.unsignedIntegerValue
    }
    self.dictionary.removeObjectForKey(key)
    self.costs.removeObjectForKey(key)
    self.dates.removeObjectForKey(key)
    self.didRemoveObjectBlock?(cache: self, key: key, object: nil)
  }
  
  func _removeObjectForKey(key: String, block: ACMemoryCacheObjectBlock) {
    dispatch_barrier_async(self.queue, { [weak self] () -> Void in
      if self == nil { return }
      self?.removeObjectAndExecuteBlocksForKey(key)
      dispatch_async(self?.queue, { [weak self] () -> Void in
        if self == nil { return }
        block(cache: self!, key: key, object: nil)
      })
    })
  }
  
  func _objectForKey(key: String, block: ACMemoryCacheObjectBlock) {
    let now = NSDate()
    dispatch_async(self.queue, { [weak self] () -> Void in
      if self == nil { return }
      var obj : AnyObject? = self?.dictionary.objectForKey(key)
      if obj != nil {
        dispatch_barrier_async(self?.queue, { [weak self] () -> Void in
          if self == nil { return }
          self?.dates.setObject(now, forKey: key)
        })
        block(cache: self!, key: key, object: obj)
      }
    })
  }
  
  func _setObject(object: AnyObject, forKey key: String, withCost cost: UInt, block: ACMemoryCacheObjectBlock) {
    let now = NSDate()
    dispatch_barrier_async(self.queue, { [weak self] () -> Void in
      if self == nil { return }
      self?.willAddObjectBlock?(cache: self!, key: key, object: object)
      self?.dictionary.setObject(object, forKey: key)
      self?.dates.setObject(now, forKey: key)
      self?.costs.setObject(NSNumber(unsignedLong: cost), forKey: key)
      self?.totoalCost += cost
      self?.didAddObjectBlock?(cache: self!, key: key, object: object)
      dispatch_async(self?.queue, { [weak self] () -> Void in
        if self == nil { return }
        block(cache: self!, key: key, object: object)
      })
    })
  }
  
  //  MARK: - External Methods
  
  func removeAllObjects(block: ACMemoryCacheBlock? = nil) {
  }
  
  func objectForKey(key: String, block: ACMemoryCacheObjectBlock? = nil) -> AnyObject? {
    if block != nil {
      self._objectForKey(key, block: block!)
      return nil
    } else {
      var obj : AnyObject? = nil
      let sema = dispatch_semaphore_create(0)
      self._objectForKey(key, block: { (cache, key, object) -> Void in
        obj = object
        dispatch_semaphore_signal(sema)
      })
      dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
      return obj
    }
  }
  
  func removeObjectForKey(key: String, block: ACMemoryCacheObjectBlock? = nil) {
    if block != nil {
      self._removeObjectForKey(key, block: block!)
    } else {
      let sema = dispatch_semaphore_create(0)
      self._removeObjectForKey(key, block: { (cache, key, object) -> Void in
        dispatch_semaphore_signal(sema); return
      })
      dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
    }
  }
  
  func setObject(object: AnyObject?, forKey key: String, withCost cost: UInt, block: ACMemoryCacheObjectBlock? = nil) {
    if object == nil {
      self.removeObjectForKey(key, block: block)
    } else {
      if block != nil {
        self._setObject(object!, forKey: key, withCost: cost, block: block!)
      } else {
        let sema = dispatch_semaphore_create(0)
        self._setObject(object!, forKey: key, withCost: cost, block: { (cache, key, object) -> Void in
          dispatch_semaphore_signal(sema)
          return
        })
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
      }
    }
  }
  
}