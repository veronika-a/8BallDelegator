import UIKit

// MARK: - deadlock with two queues
DispatchQueue.main.async {
    print("before deadlock") // flow 1
    DispatchQueue.main.sync {
        print("this code will never be executed") // flow 2
    }
    print("this one either")
}

// MARK: - cancellation of DispatchWorkItem
let dispatchQueue = DispatchQueue.global(qos: .background)
let dispatchWorkItem = DispatchWorkItem {
    while true {
        print(0)
    }
}

dispatchQueue.async(execute: dispatchWorkItem)
dispatchQueue.asyncAfter(deadline: DispatchTime.now() + 2, execute: dispatchWorkItem)

// Work Item Cancel
dispatchWorkItem.cancel()

if dispatchWorkItem.isCancelled {
    print("Task was cancelled")
}
