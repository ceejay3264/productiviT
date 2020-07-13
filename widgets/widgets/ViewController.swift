//
//  ViewController.swift
//  widgets
//
//  Created by Christopher Cordero on 6/22/20.
//  Copyright © 2020 Christopher Cordero. All rights reserved.
//

import UIKit

//PlaceHolder Struct
struct PlaceHolder {
    var filled: Bool
    // the position of a CGRect is top left
    var posX, posY: Double
    var xC, yC: Double
    var frame: CGRect
    var widget: Widget?
    var number: Int
    
    init(row: Int, column: Int) {
        self.filled = false
        self.widget = nil
        self.number = 0
        
        if((column % 2) == 0) {
            self.posX = 20
            self.xC = 108.5
        } else {
            self.posX = 217
            self.xC = 305.5
        }

        self.posY = 44 + Double(row * 185)
        self.yC = 132.5 + Double(row * 185)
        self.frame = CGRect(x: self.posX, y: self.posY, width: 177, height: 177)
    }
    
    
    mutating func setNumber(number: Int){
        self.number = number
    }
    
    mutating func setEmpty(){
        self.filled = false
    }
    
    mutating func setFilled(){
        self.filled = true
    }
}

//Double Array of All the PlaceHolders that will be on screen
struct placeHolderArray {
    
    // creates an array that can hold more arrays
    var grid = [[PlaceHolder]]()
    
    init(){
        var number = 0
        for row in (0...3){
            // creates an array that will hold the placeholder and their positions
            var newPHA = Array<PlaceHolder>()
            for column in (0...1){
                number += 1
                var newPlaceHolder = PlaceHolder(row: row, column: column)
                newPlaceHolder.setNumber(number: number)
                newPHA.append(newPlaceHolder)
            }
            // adds the new arrays for each column
            grid.append(newPHA)
        }
    }
    
    // make this along with change size. aka make sure that if a widget size 1 is on the right column, it cant change size
    mutating func updateFilled(){
        for row in (0...3){
        //iterate through columns
            for column in (0...1){
                // left column
                if(column == 0) {
                    // if its a size 1 check that box
                    if(self.grid[row][column].widget != nil && self.grid[row][column].widget?.size == 1) {
                        self.grid[row][column].filled = true
                    // if its a size 2 check that box and the one to the right
                    } else if(self.grid[row][column].widget != nil && self.grid[row][column].widget?.size == 2) {
                        self.grid[row][column].filled = true
                        self.grid[row][column+1].filled = true
                    }
                    
                    if(row <= 2) {
                        if(self.grid[row][column].widget != nil && self.grid[row][column].widget?.size == 3) {
                            self.grid[row][column].filled = true
                            self.grid[row][column+1].filled = true
                            self.grid[row+1][column].filled = true
                            self.grid[row+1][column+1].filled = true
                        }
                    }
                // right column
                } else {
                    // the only option if its the right column is if it is size 1
                    if(self.grid[row][column].widget != nil && self.grid[row][column].widget?.size == 1) {
                        self.grid[row][column].filled = true
                    }
                }
            }
        }
    }
}


//Global variables//
public var editOn = false
// holds all widgets
var screenWidgets: [Widget] = []
var placeHolders = placeHolderArray()


class ViewController: UIViewController {

    var centerX = 0
    var centerY = 0
    
    let editButton = UIButton(type: .system) // let preferred over var here
    let addWidgetButton = UIButton(type: .system)

    @IBOutlet weak var widgetMenu: UITableView!
    
    @IBAction func addWidget(_ sender: UIButton) {
        // the edit button
        if editOn == false {return}
        
        // if there is any space at all
        if self.hasNextSpot() {
            let posX = placeHolders.grid[0][0].posX
            let posY = placeHolders.grid[0][0].posY
            let newWidget = Widget(frame: CGRect(x: posX, y: posY, width: 177, height: 177))
            
            // will find the next empty space and change the center of the new widget to that one
            placeNextWidget(PHA: &placeHolders.grid, addedWidget: newWidget)
            self.view.insertSubview(newWidget, belowSubview: widgetMenu)
            screenWidgets.append(newWidget)
        }
    }
    
    func placeNextWidget(PHA: inout [[PlaceHolder]], addedWidget: Widget){
        for row in (0...3){
            for column in (0...1){
                if(PHA[row][column].filled == false) {
                    addedWidget.center = CGPoint(x: PHA[row][column].xC, y: PHA[row][column].yC)
                    addedWidget.ogPosition = CGPoint(x: PHA[row][column].posX, y: PHA[row][column].posY)
                    PHA[row][column].filled = true
                    // puts the widget to the array of placeHolders it takes
                    addedWidget.placeHoldersAccessed.append(PHA[row][column])
                    PHA[row][column].widget = addedWidget
                    return
                }
            }
        }
    }
    
    
    @IBAction func addSmartGoals(_ sender: UIButton) {
        if editOn == false{return}
        
        let smartWidget = SmartGoal(frame: CGRect(x: centerX, y: centerY, width: 177, height: 177))
        self.view.insertSubview(smartWidget, belowSubview: widgetMenu)
        screenWidgets.append(smartWidget)
        print(screenWidgets.count)
        
        centerX += 50
        centerY += 50
    }
    
    @objc func editHome(sender: UIButton!) {
        if editOn == false {editOn = true}
        else {editOn = false}
        if editOn == true {
            editButton.setTitle("done", for: .normal)
            addWidgetButton.isHidden = false
            
            if screenWidgets.count > 0{
                for i in 0...(screenWidgets.count-1) {
                    screenWidgets[i].delButton.isHidden = false
                    screenWidgets[i].sizeButton.isHidden = false
                }
            }
        }
        else {
            editButton.setTitle("edit", for: .normal)
            addWidgetButton.isHidden = true
            widgetMenu.isHidden = true
            addWidgetButton.isHidden = true
            addWidgetButton.setTitle("+", for: .normal)
            addWidgetButton.frame = CGRect(x: 20, y: 44, width: 40, height: 25)
            if screenWidgets.count > 0{
                for i in 0...(screenWidgets.count-1) {
                    screenWidgets[i].delButton.isHidden = true
                    screenWidgets[i].sizeButton.isHidden = true
                }
            }
        }
    }
    
    @objc func plusButton(sender: UIButton!) {
        if widgetMenu.isHidden == true {
            widgetMenu.isHidden = false
            addWidgetButton.setTitle("close", for: .normal)
            addWidgetButton.frame = CGRect(x: 263, y: 44, width: 40, height: 25)
        }
        else{
            widgetMenu.isHidden = true
            addWidgetButton.setTitle("+", for: .normal)
            addWidgetButton.frame = CGRect(x: 20, y: 44, width: 40, height: 25)
        }
    }
    
    func hasNextSpot() -> Bool{
        for row in (0...3){
            for column in (0...1){
                if(placeHolders.grid[row][column].filled == false){
                    return true
                }
            }
        }
        print("nope! No more space")
        return false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //print(widgetOne.center)
        editButton.frame = CGRect(x: 348, y: 44, width: 40, height: 25)
        editButton.setTitle("edit", for: .normal)
        editButton.contentHorizontalAlignment = .right
        editButton.addTarget(self, action: #selector(self.editHome), for: UIControl.Event.touchUpInside)
        self.view.addSubview(editButton)
        widgetMenu.frame = CGRect(x: 0, y: 44, width: 259, height: 769)
        widgetMenu.isHidden = true
        addWidgetButton.setTitle("+", for: .normal)
        addWidgetButton.frame = CGRect(x: 20, y: 44, width: 40, height: 25)
        editButton.contentHorizontalAlignment = .left
        addWidgetButton.addTarget(self, action: #selector(self.plusButton), for: UIControl.Event.touchUpInside)
        addWidgetButton.isHidden = true
        self.view.addSubview(addWidgetButton)
    }
    
    

}


