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

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tapView: UIView!
    
    @IBOutlet weak var searchForMovie: UISearchBar!
    
    @IBOutlet weak var networkErrorView: UILabel!
   
    @IBOutlet weak var tableView: UITableView!
    
    var textInSearchBar = ""
    
    var movies: [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        searchForMovie.delegate = self
        
        //meant to close the keyboard
        tapView.hidden = true
        
        //set network error view to invisible
        networkErrorView.hidden = true;
        
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
                                self.networkErrorView.hidden = true;
                                                                                
                            }
                    }else
                    {
                        self.networkErrorView.hidden = false;
                        
                    }
        })
        task.resume()
        
        //set up pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)


        

    }
    
    //gets standard "now playing" api request
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
    
    //standard run /w network error of some request
    func callRequest(request:NSURLRequest)
    {
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
                                if (responseDictionary["results"] == nil){
                                    self.movies = []
                                }else{
                                    self.movies = responseDictionary["results"] as! [NSDictionary]
                                }
                                                                                
                                self.tableView.reloadData()
                                print ("count: \(self.movies!.count)")
                                MBProgressHUD.hideHUDForView(self.view, animated: true)
                                self.networkErrorView.hidden = true;
                                                                                
                            }
                        }else{
                            self.networkErrorView.hidden = false;
                                                                            
                        }
        })
        task.resume()

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
                        completionHandler: { (dataOrNil, response, error) in
                                                                        
                            if let data = dataOrNil {
                                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                                    
                                    //print("response: \(responseDictionary["results"])")
                                    self.movies = responseDictionary["results"] as! [NSDictionary]
                                    self.tableView.reloadData()
                                    print ("count: \(self.movies!.count)")
                                    //MBProgressHUD.hideHUDForView(self.view, animated: true)
                                    self.networkErrorView.hidden = true;
                                    
                                }
                            }else
                            {
                                self.networkErrorView.hidden = false;
                                
                            }

                                                                        
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
        
        print(movie)
        
        //get poster
        let posterPath = movie["poster_path"]
        if let posterPath = posterPath as? NSNull{
            cell.posterView.image = UIImage(named: "ImageNotAvailable")
        }else{
            var strUrl = posterPath as! String
            strUrl = "http://image.tmdb.org/t/p/w500" + strUrl
            let imageUrl = NSURL(string: strUrl)
            cell.posterView.setImageWithURL(imageUrl!)//, placeholderImage: UIImage(named: "MovieReel"))
        }
        
        cell.titleLabel!.text = title
        cell.overviewLabel!.text = overview
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
    
    //segue to detail screen code
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! MovieDetailViewController
        let indexPath = tableView.indexPathForCell(sender as! MovieCell)
        destination.movie = movies![indexPath!.row]
    }
    
    //search bar delegate methods
    
    func searchBar(_ searchBar: UISearchBar,
                     textDidChange searchText: String)
    {
        textInSearchBar = searchText
        print(textInSearchBar)
        //searchForMovie.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchForMovie.endEditing(true)
        callRequest(getRequest())
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        textInSearchBar = textInSearchBar.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        textInSearchBar = textInSearchBar.stringByReplacingOccurrencesOfString(" ", withString: "\\%20")
        
        var urlString = "http://api.themoviedb.org/3/search/movie?query=" + textInSearchBar + "&api_key=1fca7ad4dd68a23fc671ba6deda8d707"
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        print (urlString)
        let url = NSURL(string: urlString)
        print(url)
        var request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        if (textInSearchBar == "")
        {
            request = getRequest();
        }
        
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
                                if (responseDictionary["results"] == nil)
                                {
                                    self.movies = []
                                }else{
                                    self.movies = responseDictionary["results"] as! [NSDictionary]
                                }
                            
                                self.tableView.reloadData()
                                print ("count: \(self.movies!.count)")
                                MBProgressHUD.hideHUDForView(self.view, animated: true)
                                self.networkErrorView.hidden = true;
                                                                                
                            }
                        }else
                        {
                            self.networkErrorView.hidden = false;
                                                                            
                        }
        })
        task.resume()

        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        tapView.hidden = false
    }
    
    @IBAction func tapView(sender: AnyObject) {
        searchForMovie.endEditing(true)
        tapView.hidden = true;
    }
    
}
