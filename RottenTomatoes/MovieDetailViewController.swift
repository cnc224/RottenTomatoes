//
//  MovieDetailViewController.swift
//  RottenTomatoes
//
//  Created by Ningchong Chen on 5/5/15.
//  Copyright (c) 2015 Ningchong Chen. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var detailNavigationItem: UINavigationItem!

    var movie : NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"

        
        // Do any additional setup after loading the view.
        titleLabel.text = movie!["title"] as? String
        synopsisLabel.text = movie!["synopsis"] as? String
        var posterUrl = movie!.valueForKeyPath("posters.original") as! String
        // tricky way to get high resolution image 
        var range = posterUrl.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            posterUrl = posterUrl.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        loadImage(posterUrl, completionHandler: { (image) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.posterImageView.image = image
            self.posterImageView.alpha = 0.0
            UIView.animateWithDuration(3.0, animations: {
                () -> Void in
                self.posterImageView.alpha = 1.0
            })
        })
        detailNavigationItem.title = movie!["title"] as? String
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

    let imageCache = NSCache()
    func loadImage(url: String, completionHandler: (UIImage) -> Void) {
        if let image = self.imageCache.objectForKey(url) as? UIImage {
            completionHandler(image)
        } else {
            let request = Alamofire.request(Alamofire.Method.GET, url, parameters: nil, encoding: Alamofire.ParameterEncoding.JSON)
            request.response(serializer: Request.responseDataSerializer(), completionHandler: { (_, _, data, error) in
                if error == nil {
                    let image = UIImage(data: data! as! NSData)!
                    self.imageCache.setObject(image, forKey: url)
                    completionHandler(image)
                } else {
                    self.alertNetworkError()
                }
            })
            
        }
    }
    func alertNetworkError() {
        let networkErrorAlert = UIAlertController(title: "Network Error", message: "Sorry you're offline, come back later!", preferredStyle: UIAlertControllerStyle.Alert)
        networkErrorAlert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(networkErrorAlert, animated: true, completion: nil)
    }
}
