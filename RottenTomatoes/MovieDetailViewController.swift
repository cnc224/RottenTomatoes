//
//  MovieDetailViewController.swift
//  RottenTomatoes
//
//  Created by Ningchong Chen on 5/5/15.
//  Copyright (c) 2015 Ningchong Chen. All rights reserved.
//

import UIKit
import Alamofire

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!

    var movie : NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = movie!["title"] as? String
        synopsisLabel.text = movie!["synopsis"] as? String
        let posterUrl = movie!.valueForKeyPath("posters.original") as! String
        loadImage(posterUrl, completionHandler: { (image) -> Void in
            self.posterImageView.image = image
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

    let imageCache = NSCache()
    func loadImage(url: String, completionHandler: (UIImage) -> Void) {
        if let image = self.imageCache.objectForKey(url) as? UIImage {
            completionHandler(image)
        } else {
            let request = Alamofire.request(Alamofire.Method.GET, url, parameters: nil, encoding: Alamofire.ParameterEncoding.JSON)
            request.response(serializer: Request.responseDataSerializer(), completionHandler: { (_, _, data, _) in
                
                let image = UIImage(data: data! as! NSData)!
                self.imageCache.setObject(image, forKey: url)
                completionHandler(image)
                
            })
            
        }
    }
}
