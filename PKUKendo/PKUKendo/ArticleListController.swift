//
//  ArticleListController.swift
//  PKUKendo
//
//  Created by Karma Guo on 6/17/15.
//  Copyright (c) 2015 Karma Guo. All rights reserved.
//

import UIKit

protocol ArticleChangeViewControllerDelegate:class{
    func articleChangeNeedRefresh()
}

class ArticleListController: UITableViewController ,ArticleChangeViewControllerDelegate{
    
    var articleList:[Article] = []
    var noticeList:[Notice] = []
    func articleChangeNeedRefresh() {
        self.tableView.header.beginRefreshing()
    }
    
    
    
    
    var addButton:UIBarButtonItem!
        //@IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!

    
    func showActionSheet(sender: UIBarButtonItem) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let shareLinkAction = UIAlertAction(title: "发分享", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("postShare", sender: sender)
        })
        let postArticleAction = UIAlertAction(title: "发日志", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("postArticle", sender: sender)
            //self.tableView.header.beginRefreshing()
        })

        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(postArticleAction)
        optionMenu.addAction(shareLinkAction)
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.sourceView = self.view
        optionMenu.popoverPresentationController?.barButtonItem = addButton
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //self.hidesBottomBarWhenPushed = true
        if segue.identifier == "cell"{
            var cell = sender as! ArticleCell
            var indexPath = self.tableView.indexPathForCell(cell)
            if segmentControl.selectedSegmentIndex == 0{
                (segue.destinationViewController as! ArticleController).is_article = true
                (segue.destinationViewController as! ArticleController).article = articleList[indexPath!.row]
                (segue.destinationViewController as! ArticleController).delegate = self
            }else {
                (segue.destinationViewController as! ArticleController).is_article = false
                (segue.destinationViewController as! ArticleController).notice = noticeList[indexPath!.row]
                (segue.destinationViewController as! ArticleController).delegate = self
            }
            //(segue.destinationViewController as! ArticleController).is_article
        } else if segue.identifier == "postArticle"{
            (segue.destinationViewController as! ArticlePostViewController).delegate = self
        } else if segue.identifier == "postShare"{
            (segue.destinationViewController as! ShareLinkController).delegate = self
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "showActionSheet:")
        self.navigationItem.rightBarButtonItem = addButton
        
        
        
        segmentControl.multipleTouchEnabled = false
        segmentControl.userInteractionEnabled = true
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: "shiftSegment:", forControlEvents: UIControlEvents.ValueChanged)
        
        
        var header = MJRefreshGifHeader(refreshingTarget: self, refreshingAction: "headerRefresh:")
        
        header.setImages([UIImage(named: "tiao1")!,UIImage(named: "tiao2")!],duration: 0.4, forState: MJRefreshStatePulling)
        header.setImages([UIImage(named: "tiao1")!,UIImage(named: "tiao2")!],duration: 0.4, forState: MJRefreshStateRefreshing)
        header.setImages([UIImage(named: "tiao1")!,UIImage(named: "tiao2")!],duration: 0.4, forState: MJRefreshStateIdle)
       // header.setImages(<#images: [AnyObject]!#>, duration: <#NSTimeInterval#>, forState: <#MJRefreshState#>)
        header.lastUpdatedTimeLabel.hidden = true
        header.stateLabel.hidden = true
        tableView.header = header
        
        var footer = MJRefreshBackGifFooter(refreshingTarget: self, refreshingAction: "footerRefresh:")
        footer.setImages([UIImage(named: "tiao1")!,UIImage(named: "tiao2")!],duration: 0.4, forState: MJRefreshStatePulling)
        footer.setImages([UIImage(named: "tiao1")!,UIImage(named: "tiao2")!],duration: 0.4, forState: MJRefreshStateRefreshing)
        footer.setImages([UIImage(named: "tiao1")!,UIImage(named: "tiao2")!],duration: 0.4, forState: MJRefreshStateIdle)
        //footer.lastUpdatedTimeLabel.hidden = true
        footer.stateLabel.hidden = true
        
        tableView.footer = footer

        tableView.header.beginRefreshing()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func shiftSegment(sender: UISegmentedControl){
        switch sender.selectedSegmentIndex{
        case 0:
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem = addButton
            self.tableView.header.beginRefreshing()
           // self.addButton.enabled = true
            break
        case 1:
          //  self.addButton.enabled = false
            self.navigationItem.rightBarButtonItem = nil
            self.tableView.reloadData()
            self.tableView.header.beginRefreshing()
            break
        default:
            break
        }
    }
    
    func headerRefresh(sender:MJRefreshGifHeader){
        //self.tableView.reloadData()
       // println("123")
        switch segmentControl.selectedSegmentIndex {
        case 0:
            var query = AVQuery(className: "Article")
            query.limit = 10
            query.orderByDescending("num")
            query.findObjectsInBackgroundWithBlock(){
                (results:[AnyObject]!, error:NSError!) -> Void in
                if error == nil{
                    self.articleList.removeAll(keepCapacity: true)
                    self.tableView.reloadData()
                    for result in results{
                        var articleItem = Article()
                        articleItem.commentNum = (result as! AVObject).objectForKey("commentNum") as! Int
                        articleItem.content = (result as! AVObject).objectForKey("content") as! String
                        articleItem.title = (result as! AVObject).objectForKey("title") as! String
                        articleItem.num = (result as! AVObject).objectForKey("num") as! Int
                        articleItem.likeNum = (result as! AVObject).objectForKey("likeNum") as! Int
                        articleItem.id = result.objectId
                        articleItem.is_link = (result as! AVObject).objectForKey("is_link") as! Bool
//                        var userId = (result as! AVObject).objectForKey("user") as! String
//                        var userQuery = AVUser.query()
                       // var user = userQuery.getObjectWithId(userId) as! AVUser
                        var user = (result as! AVObject).objectForKey("user") as! AVUser
                        var userId = user.objectId as String
                        articleItem.userId = userId
                        var userQuery = AVUser.query()
                        user = userQuery.getObjectWithId(userId) as! AVUser
                        var userGender = user.objectForKey("gender") as! String
                        articleItem.userName = user.objectForKey("NickName") as! String
                        var avartarFile = user.objectForKey("Avartar") as? AVFile
                        if avartarFile != nil{
                            avartarFile?.getThumbnail(true, width: 200, height: 200){
                                (img:UIImage!, error:NSError!) -> Void in
                                if error == nil{
                                    articleItem.avartar = img
                                    self.tableView.reloadData()
                                }else{
                                    if userGender == "男"{
                                        articleItem.avartar = UIImage(named: "男生默认头像")
                                    }else {
                                        articleItem.avartar = UIImage(named: "女生默认头像")
                                    }
                                }
                                
                            }
//                            var imgData = 
//                            if imgData != nil{
//                                articleItem.avartar = UIImage(data: imgData!)
//                            } else {
//                                articleItem.avartar = UIImage(named: "123")
//                            }
                        } else {
                            if userGender == "男"{
                                 articleItem.avartar = UIImage(named: "男生默认头像")
                            }else {
                                articleItem.avartar = UIImage(named: "女生默认头像")
                            }
                           // articleItem.avartar = UIImage(named: "123")
                        }
                        
                        self.articleList.append(articleItem)
                    }
                    self.tableView.reloadData()
                    self.tableView.header.endRefreshing()
                    //self.tableView.reloadData()
                } else {
                    self.tableView.header.endRefreshing()
                }
            }
            break
        case 1:
            var query = AVQuery(className: "Notice")
            query.limit = 10
            query.orderByDescending("num")
            query.findObjectsInBackgroundWithBlock(){
                (results:[AnyObject]!, error:NSError!) -> Void in
                if error == nil{
                    self.noticeList.removeAll(keepCapacity: true)
                    self.tableView.reloadData()
                    for result in results{
                        var noticeItem = Notice()
                        noticeItem.picture = UIImage(named: "1")
                        
                        noticeItem.content = (result as! AVObject).objectForKey("content") as! String
                        noticeItem.title = (result as! AVObject).objectForKey("title") as! String
                        noticeItem.num = (result as! AVObject).objectForKey("num") as! Int
                        noticeItem.commentNum = (result as! AVObject).objectForKey("commentNum") as! Int
                        noticeItem.id = result.objectId
                        noticeItem.userName = (result as! AVObject).objectForKey("userName") as! String
                        noticeItem.likeNum = (result as! AVObject).objectForKey("likeNum") as! Int
                        noticeItem.is_link = (result as! AVObject).objectForKey("is_link") as! Bool
                        if noticeItem.userName == "训练组"{
                            noticeItem.picture = UIImage(named: "训练组")
                        }else if noticeItem.userName == "联络组"{
                            noticeItem.picture = UIImage(named: "联络组")
                        }else if noticeItem.userName == "财务"{
                            noticeItem.picture = UIImage(named: "财务")
                        }else if noticeItem.userName == "社长"{
                            noticeItem.picture = UIImage(named: "社长")
                        }
                        self.noticeList.append(noticeItem)
                    }
                    self.tableView.reloadData()
                    self.tableView.header.endRefreshing()
                } else {
                    self.tableView.header.endRefreshing()
                }
            }
            break
        default:
            self.tableView.header.endRefreshing()
            break
        }
        
       // println("456")
    }
    
    func footerRefresh(sender:MJRefreshBackGifFooter){
        switch segmentControl.selectedSegmentIndex {
        case 0:
            var query = AVQuery(className: "Article")
            query.limit = 10
            if articleList.isEmpty != true{
                query.whereKey("num", lessThan: articleList[articleList.endIndex-1].num)
            }
            query.orderByDescending("num")
            query.findObjectsInBackgroundWithBlock(){
                (results:[AnyObject]!, error:NSError!) -> Void in
                if error == nil{
                    //self.articleList.removeAll(keepCapacity: true)
                    for result in results{
                        var articleItem = Article()
                        articleItem.commentNum = (result as! AVObject).objectForKey("commentNum") as! Int
                        articleItem.content = (result as! AVObject).objectForKey("content") as! String
                        articleItem.title = (result as! AVObject).objectForKey("title") as! String
                        articleItem.num = (result as! AVObject).objectForKey("num") as! Int
                        articleItem.id = result.objectId
                        articleItem.is_link = (result as! AVObject).objectForKey("is_link") as! Bool
                        articleItem.likeNum = (result as! AVObject).objectForKey("likeNum") as! Int
                        var user = (result as! AVObject).objectForKey("user") as! AVUser
                        var userId = user.objectId as String
                        articleItem.userId = userId
                        var userQuery = AVUser.query()
                        user = userQuery.getObjectWithId(userId) as! AVUser
                        var userGender = user.objectForKey("gender") as! String
                        articleItem.userName = user.objectForKey("NickName") as! String
                        var avartarFile = user.objectForKey("Avartar") as? AVFile
                        if avartarFile != nil{
                            avartarFile?.getThumbnail(true, width: 64, height: 64){
                                (img:UIImage!, error:NSError!) -> Void in
                                if error == nil{
                                    articleItem.avartar = img
                                    self.tableView.reloadData()
                                }else{
                                    if userGender == "男"{
                                        articleItem.avartar = UIImage(named: "男生默认头像")
                                    }else {
                                        articleItem.avartar = UIImage(named: "女生默认头像")
                                    }
                                }
                                
                            }
//                            var imgData = avartarFile?.getData()
//                            if imgData != nil{
//                                articleItem.avartar = UIImage(data: imgData!)
//                            } else {
//                                articleItem.avartar = UIImage(named: "123")
//                            }
                        } else {
                            if userGender == "男"{
                                articleItem.avartar = UIImage(named: "男生默认头像")
                            }else {
                                articleItem.avartar = UIImage(named: "女生默认头像")
                            }
                        }
                        
                        self.articleList.append(articleItem)
                    }
                    self.tableView.reloadData()
                    self.tableView.footer.endRefreshing()
                } else {
                    self.tableView.footer.endRefreshing()
                }
            }
            break
        case 1:
            var query = AVQuery(className: "Notice")
            query.limit = 10
            if noticeList.isEmpty != true{
                query.whereKey("num", lessThan: noticeList[noticeList.endIndex-1].num)
            }
            query.orderByDescending("num")
            query.findObjectsInBackgroundWithBlock(){
                (results:[AnyObject]!, error:NSError!) -> Void in
                if error == nil{
                    //self.noticeList.removeAll(keepCapacity: true)
                    for result in results{
                        var noticeItem = Notice()
                        noticeItem.picture = UIImage(named: "1")
                        noticeItem.userName = (result as! AVObject).objectForKey("userName") as! String
                        noticeItem.likeNum = (result as! AVObject).objectForKey("likeNum") as! Int
                        if noticeItem.userName == "训练组"{
                            noticeItem.picture = UIImage(named: "训练组")
                        }else if noticeItem.userName == "联络组"{
                            noticeItem.picture = UIImage(named: "联络组")
                        }else if noticeItem.userName == "财务"{
                            noticeItem.picture = UIImage(named: "财务")
                        }else if noticeItem.userName == "社长"{
                            noticeItem.picture = UIImage(named: "社长")
                        }
                        noticeItem.content = (result as! AVObject).objectForKey("content") as! String
                        noticeItem.title = (result as! AVObject).objectForKey("title") as! String
                        noticeItem.num = (result as! AVObject).objectForKey("num") as! Int
                        noticeItem.commentNum = (result as! AVObject).objectForKey("commentNum") as! Int
                        noticeItem.id = result.objectId
                        noticeItem.is_link = (result as! AVObject).objectForKey("is_link") as! Bool
                        self.noticeList.append(noticeItem)
                    }
                    self.tableView.reloadData()
                    self.tableView.footer.endRefreshing()
                } else {
                    self.tableView.footer.endRefreshing()
                }
            }
            break
        default:
            self.tableView.footer.endRefreshing()
            break
        }

      
    }
        
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       // tableView.header.beginRefreshing()
        
        
    }
        
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
//        if segmentControl.selected {
            if segmentControl.selectedSegmentIndex == 0{
                return articleList.count
            } else if segmentControl.selectedSegmentIndex == 1 {
                return noticeList.count
        } else {
            return 0
        }
//        } else {
//            return 0
//        }
        //return 1
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
       // self.tabBarController?.tabBar.hidden = false
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("article", forIndexPath: indexPath) as! ArticleCell

        
        cell.avatarView.layer.cornerRadius = cell.avatarView.frame.width/2
        cell.avatarView.layer.masksToBounds = true
        
        switch segmentControl.selectedSegmentIndex{
        case 0:
            let articleItem = articleList[indexPath.row]
            if articleItem.is_link == true {
                cell.titleLabel.text = articleItem.userName + " 分享链接"
                cell.commentNumField.text = "评论: \(articleItem.commentNum)"
                cell.avatarView.image = articleItem.avartar
                cell.contentLabel.text = "链接🔗 \(articleItem.title)"
            }else {
                cell.titleLabel.text = articleItem.title
                cell.commentNumField.text = "评论: \(articleItem.commentNum)"
                cell.avatarView.image = articleItem.avartar
                cell.contentLabel.text = articleItem.content
            }
            break
        case 1:
            let noticeItem = noticeList[indexPath.row]
            if noticeItem.is_link == true {
                cell.titleLabel.text = noticeItem.userName + " 分享链接"
                cell.commentNumField.text = "评论: \(noticeItem.commentNum)"
                cell.avatarView.image = noticeItem.picture
                cell.contentLabel.text = "链接🔗 \(noticeItem.title)"
            } else {
                cell.titleLabel.text = noticeItem.title
                cell.commentNumField.text = "评论: \(noticeItem.commentNum)"
                cell.avatarView.image = noticeItem.picture
                cell.contentLabel.text = noticeItem.content
            }
            break
        default:
            break
        }
        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
