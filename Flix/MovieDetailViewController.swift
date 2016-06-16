//
//  MovieDetailViewController.swift
//  Flix
//
//  Created by Prachi Bodas on 6/16/16.
//  Copyright © 2016 Prachi Bodas. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UITextView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var movie:NSDictionary = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundView()
        
        let title = movie.valueForKeyPath("title") as! String
        self.title = title
        titleLabel.text = title
        
        
        let overview = movie["overview"] as! String
        let rating = movie["vote_average"] as! Double
        let rString = String(format: "%.2f/10", rating)
        contentLabel.text = overview + "\n\nRating: " + rString
        contentLabel.editable = false
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func setBackgroundView()
    {
        //get poster
        var strUrl = movie["backdrop_path"] as! String
        strUrl = "http://image.tmdb.org/t/p/w500" + strUrl
        let imageUrl = NSURL(string: strUrl)
        backgroundImage.setImageWithURL(imageUrl!)
        
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

}
