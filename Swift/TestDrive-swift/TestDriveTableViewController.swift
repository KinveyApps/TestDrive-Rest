//
//  TestDriveTableViewController.swift
//  TestDrive-swift
//
//  Created by Michael Katz on 6/3/14.
//  Copyright (c) 2014 Kinvey. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


import UIKit

class TestDriveTableViewController: UITableViewController, ModelDelegate {

    let model: Model
    
    init(style: UITableViewStyle) {
        model = Model()
        super.init(style: style)
        // Custom initialization
        //   model = Model()
    }
    
    init(coder aDecoder: NSCoder!) {
        model = Model()
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        model.delegate = self
        model.load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return model.data.count
    }

    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell = tableView!.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let d = self.model.data[indexPath!.row]
        cell.textLabel.text = d["title"] as String
        return cell
    }

    override func tableView(tableView: UITableView!, editingStyleForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCellEditingStyle
    {
        return .Delete
    }

    override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView?, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?) {
        if editingStyle == .Delete {
            let d = self.model.data[indexPath!.row]
            model.deleteObject(d, index:indexPath!.row, completion: { (error:NSError?) in
                if error {
                    //TODO alert error
                } else {
                    tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            })
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView?, moveRowAtIndexPath fromIndexPath: NSIndexPath?, toIndexPath: NSIndexPath?) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView?, canMoveRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    func modelUpdated(model: Model) {
        self.tableView.reloadData()
    }
    
    @IBAction func add(sender : UIBarButtonItem) {
        sender.enabled = false
        
        let popup = UIAlertController(title: "New Object", message: "Set title", preferredStyle: .Alert)
        popup.addAction(UIAlertAction(title: "Save", style: .Default, handler: {(action: UIAlertAction!) -> Void in
            let tf = popup.textFields[0] as UITextField
            self.model.addObject(tf.text, completion: { (error:NSError?) in
                sender.enabled = true
                self.tableView.reloadData()
                })
            }))
        popup.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:  {(action: UIAlertAction!) -> Void in
            sender.enabled = true
        }))
        popup.addTextFieldWithConfigurationHandler  { (textField: UITextField!) -> Void in
        }
        presentViewController(popup, animated: false, completion: nil)
    }
}
