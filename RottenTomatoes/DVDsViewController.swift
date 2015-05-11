//
//  DVDsViewController.swift
//  RottenTomatoes
//
//  Created by Ningchong Chen on 5/10/15.
//  Copyright (c) 2015 Ningchong Chen. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class DVDsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var dvds: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var dvdsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO : pull this comment code out
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
        
        
        // Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        dvdsTableView.insertSubview(refreshControl, atIndex: 0)
        // end of Refresh Control
        
        // Do any additional setup after loading the view, typically from a nib.
        let rottenTomatoesURLString = "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json"
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
                    //println(data)
                    self.dvds = data["movies"] as? [NSDictionary]
                    self.dvdsTableView.reloadData()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dvds != nil ? dvds!.count: 0
    }
    
    var visited:NSMutableSet = NSMutableSet()
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = dvds![indexPath.row]
        cell.backgroundColor = visited.containsObject(movie) == true ? .lightGrayColor() : .whiteColor()
        
        // original / detailed / profile
        let posterUrl = movie.valueForKeyPath("posters.thumbnail") as! String
        // no UIImageView and UIButton extension to support async images download
        // https://github.com/Alamofire/Alamofire/pull/333
        // if import AFNetworking (before ios 7), with UIImageView+AFNetworking, use
        //cell.imageView?.setImageWithURL(NSURL(fileURLWithPath: posterUrl))
        loadImage(posterUrl, tableView: tableView, completionHandler: { (image) -> Void in
            cell.imageView?.image = image
        })
        
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        cell.index = indexPath.row

        return cell
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
