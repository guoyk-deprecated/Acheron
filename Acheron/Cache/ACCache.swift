//
//  ACCache.swift
//  Acheron-Demo
//
//  Created by Yanke Guo on 14/11/8.
//  Copyright (c) 2014年 Yanke Guo. All rights reserved.
//

import UIKit

typealias ACCacheBlock        = (cache: ACCache) -> Void
typealias ACCacheObjectBlock  = (cache: ACCache, key: String, object: AnyObject?) -> Void

let ACCacheEmptyBlock       : ACCacheBlock = { _ in }
let ACCacheEmptyObjectBlock : ACCacheObjectBlock = { _,_,_ in }

let ACCachePrefix     = "io.yanke.accache"
let ACCacheSharedName = "ACCacheShared"

var _sharedACCache : ACCache? = nil

class ACCache {
  
  var name        : String
  var queue       : dispatch_queue_t
  var diskCache   : ACDiskCache
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
    let queueName = "\(ACCachePrefix).\(name)" as NSString
    self.queue = dispatch_queue_create(queueName.UTF8String, DISPATCH_QUEUE_CONCURRENT)
    self.diskCache = ACDiskCache(name: self.name, rootPath: rootPath)
    self.memoryCache = ACMemoryCache()
  }
  
  //  MARK: - External Methods
  
  func objectForKey(key: String, block: ACCacheObjectBlock? = nil) -> AnyObject? {
    if block != nil { //  Go async
      self._objectForKey(key, block: block!)
      return nil
    } else {          //  Go sync
      var result : AnyObject? = nil
      let sema = dispatch_semaphore_create(0)
      self._objectForKey(key, block: { (cache, key, object) -> Void in
        result = object
        dispatch_semaphore_signal(sema)
      })
      dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
      return result
    }
  }
  
  func setObject(object: NSCoding?, forKey key: String, block: ACCacheObjectBlock? = nil) {
    if object == nil {    //  Invoke self.removeObject
      self.removeObjectForKey(key, block: block)
    } else {              //  Set the object
      if block != nil {     //  Go async
        self._setObject(object!, forKey: key, block: block!)
      } else {              //  Go sync
        let sema = dispatch_semaphore_create(0)
        self._setObject(object!, forKey: key, block: { (cache, key, object) -> Void in
          dispatch_semaphore_signal(sema); return
        })
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
      }
    }
  }
  
  func removeObjectForKey(key: String, block: ACCacheObjectBlock? = nil) {
    if block != nil {     //  Go async
      self._removeObjectForKey(key, block: block!)
    } else {              //  Go sync
      let sema = dispatch_semaphore_create(0)
      self._removeObjectForKey(key, block: { (cache, key, object) -> Void in
        dispatch_semaphore_signal(sema); return
      })
      dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
    }
  }
  
  //  MARK: - Internal Methods
  
  private func _objectForKey(key: String, block: ACCacheObjectBlock) {
    
    //  Dispatch in self.queue
    dispatch_async(self.queue, { [weak self] () -> Void in
      if self == nil { return }
      
      //  Query memory cache
      self?.memoryCache.objectForKey(key, block: { [weak self] (cache, key, object) -> Void in
        if self == nil { return }
        
        if object != nil {  // Found in memory
          
          // Update file date
          self?.diskCache.fileURLForKey(key, block: { (_,_,_,_) -> Void in return })
          
          //  Dispatch back to self.queue
          dispatch_async(self?.queue, { [weak self] () -> Void in
            if self == nil { return }
            
            //  Invoke the block
            block(cache: self!, key: key, object: object!)
          })
          
        } else {            // Not found in memory
          
          //  Query disk cache
          self?.diskCache.objectForKey(key, block: { [weak self] (cache, key, object, fileURL) -> Void in
            if self == nil { return }
            
            //  Set value in memory cache
            self?.memoryCache.setObject(object, forKey: key, block: nil)
            
            //  Dispatch back to self.queue
            dispatch_async(self?.queue, { [weak self] () -> Void in
              if self == nil { return }
              
              //  Invoke the block
              block(cache: self!, key: key, object: object)
            })
          })
        }
      })
    })
  }
  
  private func _setObject(object: NSCoding, forKey key: String, block: ACCacheObjectBlock) {
    //  Create and enter dispatch_group
    let group = dispatch_group_create()
    dispatch_group_enter(group)
    dispatch_group_enter(group)
    
    //  Create memoryCache and diskCache blocks
    let memBlock  : ACMemoryCacheObjectBlock  = { _,_,_   in dispatch_group_leave(group); return }
    let diskBlock : ACDiskCacheObjectBlock    = { _,_,_,_ in dispatch_group_leave(group); return }
    
    //  Set in memoryCache and diskCache
    self.memoryCache.setObject(object, forKey: key, block: memBlock)
    self.diskCache.setObject(object, forKey: key, block: diskBlock)
    
    //  Invoke the block
    dispatch_group_notify(group, self.queue) { [weak self] () -> Void in
      if self == nil { return }
      block(cache: self!, key: key, object: object)
    }
  }
  
  private func _removeObjectForKey(key: String, block: ACCacheObjectBlock) {
    //  Create and enter dispatch_group
    let group = dispatch_group_create()
    dispatch_group_enter(group)
    dispatch_group_enter(group)
    
    //  Create memoryCache and diskCache blocks
    let memBlock : ACMemoryCacheObjectBlock = { _,_,_   in dispatch_group_leave(group); return }
    let diskBlock: ACDiskCacheObjectBlock   = { _,_,_,_ in dispatch_group_leave(group); return }
    
    //  Remove in memoryCache and diskCache
    self.memoryCache.removeObjectForKey(key, block: memBlock)
    self.diskCache.removeObjectForKey(key, block: diskBlock)
    
    //  Invoke the block
    dispatch_group_notify(group, self.queue) { [weak self] () -> Void in
      if self == nil { return }
      block(cache: self!, key: key, object: nil)
    }
  }
  
  private func _removeAllObjects(block: ACCacheBlock) {
    //  Create and enter dispatch_group
    let group = dispatch_group_create()
    dispatch_group_enter(group)
    dispatch_group_enter(group)
    
    //  Create memoryCache and diskCache blocks
    let memBlock : ACMemoryCacheBlock = { _ in dispatch_group_leave(group); return }
    let diskBlock: ACDiskCacheBlock   = { _ in dispatch_group_leave(group); return }
    
    //  Remove all objects from memoryCache and diskCache
    self.memoryCache.removeAllObjects(memBlock)
    self.diskCache.removeAllObjects(diskBlock)
    
    //  Invoke the block
    dispatch_group_notify(group, self.queue) { [weak self] () -> Void in
      if self == nil { return }
      block(cache: self!)
    }
  }
  
  // MARK: - Subscript
  
  subscript(key: String) -> AnyObject? {
    get {
      return self.objectForKey(key)
    }
    set(newValue) {
      self.setObject(newValue as? NSCoding, forKey: key)
    }
  }
  
}