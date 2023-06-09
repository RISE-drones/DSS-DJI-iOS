//
//  Retry.swift
//  DSS
//
//  Created by Andreas Gising on 2021-04-28.
//

// Never used, but can be useful..

import Foundation

class RetryManager: NSObject {
    private let queue = DispatchQueue(label: "YOUR_LABEL_HERE")
    private let semaphore = DispatchSemaphore(value: 0)
    private var errorToCheck:NSError? = NSError()
    override init() {
        
    }
    
    open func runBlock(withRetries retry: Int, _ block: @escaping () -> Void) {
        queue.async {
            var counter = 1
            while self.errorToCheck != nil {
                self.dispatchNow(block)
                _ = self.semaphore.wait(timeout: .now() + 2)
                if counter >= retry {
                    break
                }
                counter += 1
            }
        }
    }
    
    open func proceed() {
        self.semaphore.signal()
    }
    
    open func stop() {
        errorToCheck = nil
    }
    
    fileprivate func dispatchNow(_ block: ()->()) {
        block()
    }
}
