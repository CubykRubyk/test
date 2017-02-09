//
//  ViewController.swift
//  Checklist
//
//  Created by Dominic Maguire on 29/03/2016.
//  Copyright © 2016 Dominic Maguire. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController, ItemDetailViewControllerDelegate {
    
    var checklist: Checklist!
    
   /* func loadChecklistItems() {
        // 1
        let path = dataFilePath()
        // 2
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            //3
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                items = unarchiver.decodeObjectForKey("ChecklistItems") as! [ChecklistItem]
                unarchiver.finishDecoding()
            }
        }
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()
        title = checklist.name
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* actually named tableView(numberOfRowsInSection) 
       '->' denotes method return type */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.items.count
    }
    
    // actually named tableView(cellForRowAtIndexPath)
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "ChecklistItem", forIndexPath: indexPath)
        
        let item = checklist.items[indexPath.row]
        
        configureTextForCell(cell, withChecklistItem: item)
        configureCheckmarkForCell(cell, withCheckListItem: item)
        
        return cell
    }
    
    // actually named tableView(didSelectRowAtIndexPath)
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            
            let item = checklist.items[indexPath.row]
            item.toggleChecked()
            configureCheckmarkForCell(cell, withCheckListItem: item)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    /*
     * Remove items from table view
     *
     */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        // 1
        checklist.items.removeAtIndex(indexPath.row)
        // 2
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    
    func configureCheckmarkForCell(cell: UITableViewCell, withCheckListItem item: ChecklistItem) {
        
        let label = cell.viewWithTag(1001) as! UILabel
        label.textColor = view.tintColor
        if item.checked {
            label.text = "✓"
        } else {
            label.text = ""
        }
    }
    
    func configureTextForCell(cell: UITableViewCell, withChecklistItem item: ChecklistItem) {
        let label = cell.viewWithTag(1000) as! UILabel
        let dateLabel = cell.viewWithTag(2000) as! UILabel
        
        label.text = item.text
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        dateLabel.text = formatter.stringFromDate(item.dueDate)
    }
    
    
    func itemDetailViewControllerDidCancel(controller: ItemDetailViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func itemDetailViewController(controller: ItemDetailViewController, didFinishAddingItem item: ChecklistItem) {
        let newRowIndex = checklist.items.count
        
        checklist.items.append(item)
        sortItems()
        
        let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
        let indexPaths = [indexPath]
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func itemDetailViewController(controller: ItemDetailViewController, didFinishEditingItem item: ChecklistItem) {
        if let index = checklist.items.indexOf(item) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                configureTextForCell(cell, withChecklistItem: item)
            }
        }
        
        sortItems()
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 1
        if segue.identifier == "AddItem" {
            //2
            let navigationController = segue.destinationViewController as! UINavigationController
        
            // 3
            let controller = navigationController.topViewController as! ItemDetailViewController
            
            // 4
            controller.delegate = self
        } else if segue.identifier == "EditItem" {
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! ItemDetailViewController
            controller.delegate = self
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                controller.itemToEdit = checklist.items[indexPath.row]
            }
        }
            
    }
    
    func sortItems() {
        checklist.items.sortInPlace({ item1, item2 in return
            item1.dueDate.compare(item2.dueDate) == .OrderedAscending })
    }
    
    /*func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("Checklists.plist")
    }
    
    func saveChecklistItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(items, forKey: "ChecklistItems")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }*/
    
}

