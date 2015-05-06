//
//  ViewController.swift
//  RottenTomatoes
//
//  Created by Ningchong Chen on 5/4/15.
//  Copyright (c) 2015 Ningchong Chen. All rights reserved.
//

import UIKit
import Alamofire

class MovieTableViewController: UITableViewController {

    var movies : [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // TODO use alamofire to get movies
        //
        // codepath rotten tomatoes api key
        // dagqdghwaq3e3mxyrp7kmmj5
        // my key cqaftwkqjceybpze2mrfhn7n
        let apiKey = "dagqdghwaq3e3mxyrp7kmmj5" // Fill with the key you registered at http://developer.rottentomatoes.com
        let rottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=" + apiKey
        let request = Alamofire.request(Alamofire.Method.GET, rottenTomatoesURLString, parameters: nil, encoding: Alamofire.ParameterEncoding.JSON)
        request.responseString(encoding: nil, completionHandler: { (request, response, body, error) in
            // TODO error handler
            if let body = body {
                //NSLog(body)
                let data = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                // TODO error handler
                let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.tableView.reloadData()
                }

            }
        })
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        
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
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! MovieCell
        let movie = movies![cell.index!]
        let movieDetailViewController = segue.destinationViewController as! MovieDetailViewController
        movieDetailViewController.movie = movie
    }
    
    let imageCache = NSCache()
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
}

