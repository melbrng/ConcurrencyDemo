//
//  ViewController.swift
//  ConcurrencyDemo
//
//  Created by Hossam Ghareeb on 11/15/15.
//  Copyright © 2015 Hossam Ghareeb. All rights reserved.
//

import UIKit


public enum NSOperationQueuePriority : Int {
    case VeryLow
    case Low
    case Normal
    case High
    case VeryHigh
}

let imageURLs = ["http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg", "http://adriatic-lines.com/wp-content/uploads/2015/04/canal-of-Venice.jpg", "http://algoos.com/wp-content/uploads/2015/08/ireland-02.jpg", "http://bdo.se/wp-content/uploads/2014/01/Stockholm1.jpg"]

class Downloader {
    
    class func downloadImageWithURL(url:String) -> UIImage! {
        
        let data = NSData(contentsOfURL: NSURL(string: url)!)
        return UIImage(data: data!)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBOutlet weak var sliderValueLabel: UILabel!
    
    var queue = NSOperationQueue()
    
    var operation1 = NSBlockOperation()
    var operation2 = NSBlockOperation()
    var operation3 = NSBlockOperation()
    var operation4 = NSBlockOperation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didClickOnStart(sender: AnyObject) {
        
        //dependencies for calling nsBlockOperation
        operation2.addDependency(operation1)
        operation3.addDependency(operation2)
        
    }
    
    @IBAction func didClickOnCancel(sender: AnyObject) {
        
        self.queue.cancelAllOperations()
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        
        self.sliderValueLabel.text = "\(sender.value * 100.0)"
    }
    
    //MARK: Dispatch Queues
    //Downloads are submitted as concurrent tasks to the default queue
    func concurrentOnDefaultQueue() {
        
        //submit image downloads as concurrent tasks to the default queue
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        //download on background
        dispatch_async(queue){ () -> Void in
            
            let img1 = Downloader.downloadImageWithURL(imageURLs[0])
            
            //execute UI related tasks on main queue
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView1.image = img1
                
            })
            
        }
        
        dispatch_async(queue) { () -> Void in
            
            let img2 = Downloader.downloadImageWithURL(imageURLs[1])
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView2.image = img2
            })
            
        }
        dispatch_async(queue) { () -> Void in
            
            let img3 = Downloader.downloadImageWithURL(imageURLs[2])
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView3.image = img3
            })
            
        }
        dispatch_async(queue) { () -> Void in
            
            let img4 = Downloader.downloadImageWithURL(imageURLs[3])
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView4.image = img4
            })
        }

    }
    
    //Default serial queue is the main queue for the UI , so you have to create a new serialQueue
    //Serial so images load one after the other  (waits for previous task to finish before execution)
    func serialQueue(){
        let serialQueue = dispatch_queue_create("com.appcoda.imagesQueue", DISPATCH_QUEUE_SERIAL)
        
        
        dispatch_async(serialQueue) { () -> Void in
            
            let img1 = Downloader .downloadImageWithURL(imageURLs[0])
            
            //same as before, pop back onto the main queue for UI related stuff
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView1.image = img1
            })
            
        }
        dispatch_async(serialQueue) { () -> Void in
            
            let img2 = Downloader.downloadImageWithURL(imageURLs[1])
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView2.image = img2
            })
            
        }
        dispatch_async(serialQueue) { () -> Void in
            
            let img3 = Downloader.downloadImageWithURL(imageURLs[2])
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView3.image = img3
            })
            
        }
        dispatch_async(serialQueue) { () -> Void in
            
            let img4 = Downloader.downloadImageWithURL(imageURLs[3])
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView4.image = img4
            })
        }
    }
    
    //MARK: Operation Queues
    //High level abstraction of the queue model build on top of GCD
    //Can execute tasks concurrently but in an object oriented fashion
    //Op queues don't conform to FIFO (like dispatch queues) you can set a priority for operations and add dependencies
    //Operate concurrently by default (cannot change to serial) but can use dependencies between for a workaround
    //Tasks are encapsulated in instances of NSOperation (not blocks) - a single unit of work
    
    //allows downloading of images in the background
    func nsAddOperationBlockQueue(){
        
        queue = NSOperationQueue()

        queue.addOperationWithBlock { () -> Void in

            let img1 = Downloader.downloadImageWithURL(imageURLs[0])

            //pop back on main thread
            NSOperationQueue.mainQueue().addOperationWithBlock({
            self.imageView1.image = img1
            })
        }

        queue.addOperationWithBlock { () -> Void in
            let img2 = Downloader.downloadImageWithURL(imageURLs[1])

            NSOperationQueue.mainQueue().addOperationWithBlock({
            self.imageView2.image = img2
            })

        }

        queue.addOperationWithBlock { () -> Void in
            let img3 = Downloader.downloadImageWithURL(imageURLs[2])

            NSOperationQueue.mainQueue().addOperationWithBlock({
            self.imageView3.image = img3
            })

        }

        queue.addOperationWithBlock { () -> Void in
            let img4 = Downloader.downloadImageWithURL(imageURLs[3])

            NSOperationQueue.mainQueue().addOperationWithBlock({
            self.imageView4.image = img4
            })

        }
    }
    
    
    //Encapsulate the operation in a block and when done, completion handler is called
    //BlockOperation allows management of operations and more functionality
    func nsBlockOperation(){
        
        queue = NSOperationQueue()
        operation1 = NSBlockOperation(block: {
            
            let img1 = Downloader.downloadImageWithURL(imageURLs[0])
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView1.image = img1
            })
        })
        
        operation1.completionBlock = {
            print("Operation 1 completed, cancelled:\(self.operation1.cancelled) ")
        }
        
        queue.addOperation(operation1)
        
        operation2 = NSBlockOperation(block: {
            let img2 = Downloader.downloadImageWithURL(imageURLs[1])
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView2.image = img2
            })
        })
        
        operation2.completionBlock = {
            print("Operation 2 completed")
        }
        queue.addOperation(operation2)
        
        
        operation3 = NSBlockOperation(block: {
            let img3 = Downloader.downloadImageWithURL(imageURLs[2])
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView3.image = img3
            })
        })
        
        operation3.completionBlock = {
            print("Operation 3 completed")
        }
        queue.addOperation(operation3)
        
        operation4 = NSBlockOperation(block: {
            let img4 = Downloader.downloadImageWithURL(imageURLs[3])
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView4.image = img4
            })
        })
        
        operation4.completionBlock = {
            print("Operation 4 completed")
        }
        queue.addOperation(operation4)
    }
    


}

