//
//  ViewController.swift
//  RottenTomatoes
//
//  Created by Ningchong Chen on 5/4/15.
//  Copyright (c) 2015 Ningchong Chen. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class MovieTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var movies : [NSDictionary]?
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var movieTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO : pull this comment code out
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
        
        
        // Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        movieTableView.insertSubview(refreshControl, atIndex: 0)
        // end of Refresh Control
        
        // Do any additional setup after loading the view, typically from a nib.
        let rottenTomatoesURLString = "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"
//        let rottenTomatoesURLString = "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json"
        let request = Alamofire.request(Alamofire.Method.GET, rottenTomatoesURLString, parameters: nil, encoding: Alamofire.ParameterEncoding.JSON)
        request.responseJSON(options: nil, completionHandler: { (_, _, data, error) in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if let error = error {
                println(error)
                // TODO show error message
                let networkErrorAlert = UIAlertController(title: "Network Error", message: "Sorry you're offline, come back later!", preferredStyle: UIAlertControllerStyle.Alert)
                networkErrorAlert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(networkErrorAlert, animated: true, completion: nil)
            } else {
                if let data = data as? NSDictionary {
            
                    self.movies = data["movies"] as? [NSDictionary]
                    self.movieTableView.reloadData()
                }
            }
        })
        
        // example
        //Alamofire.request(.Get, URLString: rottenTomatoesURLString);
        
        /*let manager = AFHTTPRequestOperationManager()
        
        manager.GET(rottenTomatoesURLString, parameters: nil, success: { (operation: AFHTTPRequestOperation!, resp: AnyObject!) -> Void in
        
            }, failure: { (operation: AFHTTPRequestOperation!, err: NSError!) -> Void in
                // TODO
                
        })*/

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    var visited:NSMutableSet = NSMutableSet()
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        cell.backgroundColor = visited.containsObject(movie) == true ? .lightGrayColor() : .whiteColor()
        
        // original / detailed / profile
        let posterUrl = movie.valueForKeyPath("posters.thumbnail") as! String
        // no UIImageView and UIButton extension to support async images download
        // https://github.com/Alamofire/Alamofire/pull/333
        loadImage(posterUrl, tableView: tableView, completionHandler: { (image) -> Void in
            cell.imageView?.image = image
        })
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        cell.index = indexPath.row
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! MovieCell
        cell.backgroundColor = .lightGrayColor()
        let movie = movies![cell.index!]
        visited.addObject(movie)
        let movieDetailViewController = segue.destinationViewController as! MovieDetailViewController
        movieDetailViewController.movie = movie
    }
    
    // cache the image
    let imageCache = NSCache()
    // async load image
    func loadImage(url: String, tableView: UITableView, completionHandler: (UIImage) -> Void) {
        if let image = self.imageCache.objectForKey(url) as? UIImage {
            completionHandler(image)
        } else {
            let request = Alamofire.request(Alamofire.Method.GET, url, parameters: nil, encoding: Alamofire.ParameterEncoding.JSON)
            request.response(serializer: Request.responseDataSerializer(), completionHandler: { (_, _, data, _) in
                
                let image = UIImage(data: data! as! NSData)!
                self.imageCache.setObject(image, forKey: url)
                completionHandler(image)
                tableView.reloadData()

            })

        }
    }
    
    // Refresh Control
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            // TODO : pull request again here
            // only call once at same time. 
            // no need to check if there are more refresh
            self.refreshControl.endRefreshing()
        })
    }
    // end of Refresh Control
}

