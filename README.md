## Rotten Tomatoes

This is a movies app displaying box office and top rental DVDs using the [Rotten Tomatoes API](http://developer.rottentomatoes.com/docs/read/JSON).

Time spent: `15 hours`

### Features

#### Required

- [x] User can view a list of movies. Poster images load asynchronously. I am using alamofire, so I implemented async with alamofire instead of using UIImageView+AFNetworking. 
- [x] User can view movie details by tapping on a cell.
- [x] User sees loading state while waiting for the API. Using MBProgressHUD.
- [x] User sees error message when there is a network error. Using UIAlertController.
- [x] User can pull to refresh the movie list. Using UIRefreshControl.

#### Optional

- [x] All images fade in. fade in 3 seconds.
- [ ] For the larger poster, load the low-res first and switch to high-res when complete.
- [x] All images should be cached in memory and disk: I used NSCache instead of (AppDelegate has an instance of `NSURLCache` and `NSURLRequest` makes a request with `NSURLRequestReturnCacheDataElseLoad` cache policy). I tested it by turning off wifi and restarting the app.
- [x] Customize the highlight and selection effect of the cell. When the cell is clicked, it will be marked in grey as viewed.
- [x] Customize the navigation bar. Show movie name.
- [x] Add a tab bar for Box Office and DVD.
- [ ] Add a search bar: pretty simple implementation of searching against the existing table view data.

### Walkthrough
![Video Walkthrough](https://github.com/cnc224/RottenTomatoes/RottenTomatoes.gif)

Credits
---------
* [Rotten Tomatoes API](http://developer.rottentomatoes.com/docs/read/JSON)
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
