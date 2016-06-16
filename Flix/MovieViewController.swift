//
//  MovieViewController.swift
//  Flix
//
//  Created by Prachi Bodas on 6/15/16.
//  Copyright © 2016 Prachi Bodas. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
   
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        //get JSON data
        
        
        let request = getRequest()
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
                completionHandler: { (dataOrNil, response, error) in
                    if let data = dataOrNil {
                            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                                
                                print("response: \(responseDictionary["results"])")
                                self.movies = responseDictionary["results"] as! [NSDictionary]
                                self.tableView.reloadData()
                                print ("count: \(self.movies!.count)")
                                MBProgressHUD.hideHUDForView(self.view, animated: true)
                                                                                
                                            }
                    }
        })
        task.resume()
        
        //set up pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)


        

    }
    
    func getRequest() -> NSURLRequest
    {
        let apiKey = "1fca7ad4dd68a23fc671ba6deda8d707"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        return request
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //refresh control methods
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // ... Create the NSURLRequest (myRequest) ...
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(getRequest(),
                                                                      completionHandler: { (data, response, error) in
                                                                        
                                                                        // ... Use the new data to update the data source ...
                                                                        
                                                                        // Reload the tableView now that there is new data
                                                                        self.tableView.reloadData()
                                                                        
                                                                        // Tell the refreshControl to stop spinning
                                                                        refreshControl.endRefreshing()
        });
        task.resume()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //Data Source Methods
    
    func tableView(tableView: UITableView,
                     cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell",forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        //get poster
        var strUrl = movie["poster_path"] as! String
        strUrl = "http://image.tmdb.org/t/p/w500" + strUrl
        let imageUrl = NSURL(string: strUrl)
        
        cell.titleLabel!.text = title
        cell.overviewLabel!.text = overview
        cell.posterView.setImageWithURL(imageUrl!)//, placeholderImage: UIImage(named: "MovieReel"))
        return cell
        
    }
    
    func tableView(tableView: UITableView,
                     numberOfRowsInSection section: Int) -> Int
    {
        if (self.movies == nil)
        {
            return 0
        }else{
            return self.movies!.count
        }
    }


}
