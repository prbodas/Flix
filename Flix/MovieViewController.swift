//
//  MovieViewController.swift
//  Flix
//
//  Created by Prachi Bodas on 6/15/16.
//  Copyright © 2016 Prachi Bodas. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
   
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        //get JSON data
        
        let apiKey = "1fca7ad4dd68a23fc671ba6deda8d707"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
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
                                                                                
                                            }
                    }
        })
        task.resume()

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
    
    //Data Source Methods
    
    func tableView(tableView: UITableView,
                     cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell",forIndexPath: indexPath)
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        cell.textLabel!.text = title
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
