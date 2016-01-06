//
//  FeedTableViewController.swift
//  RSSFeedReader
//
//  Created by Administrateur on 06/01/2016.
//  Copyright © 2016 com.epsi.projeti5.rssfeedreader. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController, MWFeedParserDelegate, SideBarDelegate {

    var feedItems = [MWFeedItem]()
    var sideBar = SideBar()
    var savedFeeds = [Feed]()
    var feedNames = [String]()
    
    //http://www.nytimes.com/services/xml/rss/nyt/Education.xml
    func request(urlString: String?) {
        
        if urlString == nil {
            
            let url = NSURL(string: "http://www.feeds.nytimes.com/nyt/rss/Technology")
            let feedParser = MWFeedParser(feedURL: url)
            feedParser.delegate = self
            feedParser.parse()
        } else {
            let url = NSURL(string: urlString!)
            let feedParser = MWFeedParser(feedURL: url)
            feedParser.delegate = self
            feedParser.parse()
        }
    }
    
    func loadSavedFeeds() {
        savedFeeds = [Feed]()
        feedNames = [String]()
        
        feedNames.append("Add feed")
        
        let moc = SwiftCoreDataHelper.managedObjectContext()
        
        let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Feed), withPredicate: nil, managedObjectContext: moc)
        
        if results.count > 0 {
            for feed in results {
                let f = feed as! Feed
                savedFeeds.append(f)
                feedNames.append(f.name!)
            }
        }
        
        sideBar = SideBar(sourceView: self.navigationController!.view, menuItems: feedNames)
        sideBar.delegate = self
    }
    
    // Feed Parser Delegate
    func feedParserDidStart(parser: MWFeedParser!) {
        feedItems = [MWFeedItem]()
    }
    
    func feedParserDidFinish(parser: MWFeedParser!) {
        self.tableView.reloadData()
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
        print(info)
        self.title = info.title
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        feedItems.append(item)
    }
    
    // SideBar delegate
    
    func sideBarDidSelectMenuButtonAtIndex(index: Int) {
        if index == 0 { // Add feed button
            let alert = UIAlertController(title: "Add new feed ", message: "Enter feed name and URL", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler({ (textField:UItextField!) -> Void in
                textField.placeholder = "Feed name"
            })
            alert.addTextFieldConfigurationHandler({ (TextField:UITextField!) -> Void in
                textField.placeholder = "Feed URL"
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { (AlertAction: UIAlertAction!) -> Void in
                let textFields = alert.textFields
                
                let feedNameTextField = textFields?.first as UITextField?
                let feedURLTextField = textFields?.first as UITextField?
                
                if feedNameTextField!.text != "" && feedURLTextField!.text != "" {
                    let moc = SwiftCoreDataHelper.managedObjectContext()
                    
                    let feed =  SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Feed), managedObjectConect: moc) as! Feed
                    
                    feed.name = feedNameTextField?.text
                    feed.url = feedURLTextField?.text
                    
                    SwiftCoreDataHelper.saveManagedObjectContext(moc)
                    
                    self.loadSavedFeeds()
                }
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let moc = SwiftCoreDataHelper.managedObjectContext()
            
            let selectedFeed = moc.existingObjectWithID(savedFeeds[index - 1].objectID, error: nil) as Feed
            
            request(selectedFeed.url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedFeeds()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        request(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection sections: Int) -> Int {
        return feedItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell
        let item = feedItems[indexPath.row] as MWFeedItem
        cell.textLabel?.text = item.title
        
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = feedItems[indexPath.row] as MWFeedItem
        
        let webBrowser = KINWebBrowserViewController()
        let url = NSURL (string: item.link)
        
        webBrowser.loadURL(url)
        
        self.navigationController?.pushViewController(webBrowser, animated: true)
    }

}
