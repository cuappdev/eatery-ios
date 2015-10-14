//
//  Calendars.swift
//  Eatery
//
//  Created by Eric Appel on 5/5/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation
import SwiftyJSON

private let kMenuNotAvailable = "Menu not available."
let kGeneralMealTypeName = "Menu"
private let kMenuCategoryName = "General"

let kEateryGeneralMenus: [String : JSON] =
[
    "Amit-Bhatia-Libe-Cafe" :
        [
            [
                "category"  : kMenuCategoryName,
                "items": [
                    [
                        "item": "Starbucks Specialty Coffee",
                        "healthy": false
                    ],
                    [
                        "item": "Tazo Tea",
                        "healthy": false
                    ],
                    [
                        "item": "Hot Cocoa",
                        "healthy": false
                    ],
                    [
                        "item": "Frappuccino",
                        "healthy": false
                    ],
                    [
                        "item": "Pepsi Beverages",
                        "healthy": false
                    ],
                    [
                        "item": "nSmoothies",
                        "healthy": false
                    ],
                    [
                        "item": "Baked Goods",
                        "healthy": false
                    ],
                    [
                        "item": "Sushi",
                        "healthy": false
                    ],
                    [
                        "item": "Grab-n-Go items",
                        "healthy": false
                    ]
                ]
            ]
    ],
    "Atrium-Cafe" :
        [
            
            [
                "category"  : kMenuCategoryName,
                "items" : [
                    [
                        "item": "Starbucks Specialty Coffee",
                        "healthy": false
                    ],
                    [
                        "item": "Tazo Tea",
                        "healthy": false
                    ],
                    [
                        "item": "Hot Cocoa",
                        "healthy": false
                    ],
                    [
                        "item": "Pepsi Beverages",
                        "healthy": false
                    ],
                    [
                        "item": "Pizza",
                        "healthy": false
                    ],
                    [
                        "item": "Dim Sum",
                        "healthy": false
                    ],
                    [
                        "item": "Salads",
                        "healthy": false
                    ],
                    [
                        "item": "Soups",
                        "healthy": false
                    ],
                    [
                        "item": "Chili",
                        "healthy": false
                    ],
                    [
                        "item": "Hot and Cold Specialty Sandwiches",
                        "healthy": false
                    ],
                    [
                        "item": "Build Your Own Sandwich",
                        "healthy": false
                    ],
                    [
                        "item": "Sushi",
                        "healthy": false
                    ],
                    [
                        "item": "Grab-n-Go Items",
                        "healthy": false
                    ],
                ]
            ]
    ],
    "Bear-Necessities" :
        [
            
            [
                "category"  : kMenuCategoryName,
                "items": [
                    [
                        "healthy": 0,
                        "item": "Starbucks Coffee"
                    ],
                    [
                        "healthy": 0,
                        "item": "Tazo Tea"
                    ],
                    [
                        "healthy": 0,
                        "item": "Hot Cocoa"
                    ],
                    [
                        "healthy": 0,
                        "item": "Pepsi Beverages"
                    ],
                    [
                        "healthy": 0,
                        "item": "Breakfast Menu"
                    ],
                    [
                        "healthy": 0,
                        "item": "Deli Sandwiches"
                    ],
                    [
                        "healthy": 0,
                        "item": "Burgers"
                    ],
                    [
                        "healthy": 0,
                        "item": "Hot Dogs"
                    ],
                    [
                        "healthy": 0,
                        "item": "Wings"
                    ],
                    [
                        "healthy": 0,
                        "item": "Pizza"
                    ],
                    [
                        "healthy": 0,
                        "item": "Calzones"
                    ],
                    [
                        "healthy": 0,
                        "item": "Soup"
                    ],
                    [
                        "healthy": 0,
                        "item": "Chili"
                    ],
                    [
                        "healthy": 0,
                        "item": "Fries"
                    ],
                    [
                        "healthy": 0,
                        "item": "Mozzarella Sticks"
                    ],
                    [
                        "healthy": 0,
                        "item": "Onion Petals"
                    ],
                    [
                        "healthy": 0,
                        "item": "and Grab-n-Go items."
                    ]
                ]
            ], [
                "category"  : "Special Note",
                "items": [
                    [
                        "item": "During the summer\nthe Bear Necessities deli and salad counter is closed\nand the grill closes at 2pm Monday through Friday. Pizza and calzones are available throughout open hours\nand there are FreshTake sandwiches and salads in the cooler.",
                        "healthy": false
                    ]
                ]
            ]
    ],
    "Bears-Den" :
        [
            
            [
                "category"  : kMenuCategoryName,
                "items": [
                    [
                        "healthy": 0,
                        "item": "New York Style Pizza"
                    ],
                    [
                        "healthy": 0,
                        "item": "Ivy Room Grinders"
                    ],
                    [
                        "healthy": 0,
                        "item": "garlic knots"
                    ],
                    [
                        "healthy": 0,
                        "item": "Pepsi beverages"
                    ],
                    [
                        "healthy": 0,
                        "item": "beer and wine."
                    ]
                ]
            ]
    ],
    "Big-Red-Barn" :
        [
            
            [
                "category"  : kMenuCategoryName,
                "items": [
                    [
                        "healthy": 0,
                        "item": "Finger Lakes Coffee"
                    ],
                    [
                        "healthy": 0,
                        "item": "Mighty Leaf Tea"
                    ],
                    [
                        "healthy": 0,
                        "item": "Pepsi Beverages"
                    ],
                    [
                        "healthy": 0,
                        "item": "Salads"
                    ],
                    [
                        "healthy": 0,
                        "item": "Breakfast Menu"
                    ],
                    [
                        "healthy": 0,
                        "item": "Pasta"
                    ],
                    [
                        "healthy": 0,
                        "item": "Pizza"
                    ],
                    [
                        "healthy": 0,
                        "item": "Deli and Specialty Sandwiches"
                    ],
                    [
                        "healthy": 0,
                        "item": "Subs and Grab-n-Go items."
                    ]
                ]
            ]
    ],
    "Cafe-Jennie" :
        [
            
            [
                "category"  : kMenuCategoryName,
                "items" : [
                    [
                        "item": "Join us in the morning for Steel Cut Oatmeal, Chobani Greek Style Yogurt, or Chorizo or a Vegetable Frittata Bagel Sandwich. Pop by at lunchtime for one of our creative new sandwiches and wraps\nlike Beef Brisket, Roasted Vegetable Focaccia, or Thai Chicken. Or visit any time for brewed coffee or tea or an espresso beverage made with Peet's Coffee.",
                        "healthy": 0
                    ]
                ]
            ]
    ],
    "Carols-Cafe" :
        [
            [
                "category"  : kMenuCategoryName,
                "items": [
                    [
                        "healthy": 0,
                        "item": "Starbucks Specialty Coffees"
                    ],
                    [
                        "healthy": 0,
                        "item": "Tazo Tea"
                    ],
                    [
                        "healthy": 0,
                        "item": "Hot Cocoa"
                    ],
                    [
                        "healthy": 0,
                        "item": "Frappuccino"
                    ],
                    [
                        "healthy": 0,
                        "item": "Smoothies"
                    ],
                    [
                        "healthy": 0,
                        "item": "Pepsi Beverages"
                    ],
                    [
                        "healthy": 0,
                        "item": "Baked Goods"
                    ],
                    [
                        "healthy": 0,
                        "item": "Sushi"
                    ],
                    [
                        "healthy": 0,
                        "item": "and Grab-n-Go items."
                    ],
                ]
            ]
    ],
    "Cornell-Dairy-Bar" :
        [
            [
                "category": "Current Cornell Dairy ice cream flavors",
                "items": [
                    [
                        "healthy": 0,
                        "item": "Mint Chocolate Cookie"
                    ]   ]
            ]
    ],
    "Goldies-Cafe" :
        [
            
            [
                "category"  : kMenuCategoryName,
                "items": [
                    [
                        "healthy": 0,
                        "item": "Starbucks Specialty Coffees"
                    ],
                    [
                        "healthy": 0,
                        "item": "Tazo Tea"
                    ],
                    [
                        "healthy": 0,
                        "item": "Hot Cocoa"
                    ],
                    [
                        "healthy": 0,
                        "item": "Frappuccino"
                    ],
                    [
                        "healthy": 0,
                        "item": "Pepsi Beverages"
                    ],
                    [
                        "healthy": 0,
                        "item": "Soup"
                    ],
                    [
                        "healthy": 0,
                        "item": "Breakfast Sandwiches"
                    ],
                    [
                        "healthy": 0,
                        "item": "Deli and Signature Sandwiches"
                    ],
                    [
                        "healthy": 0,
                        "item": "Sushi"
                    ],
                    [
                        "healthy": 0,
                        "item": "Baked Goods"
                    ],
                    [
                        "healthy": 0,
                        "item": "and Grab-n-Go items."
                    ]
                ]
            ]
    ],
    "Green-Dragon" :
        [
            
            [
                "category"  : kMenuCategoryName,
                "items": [
                    [
                        "healthy": 0,
                        "item": "Finger Lakes Specialty Coffees"
                    ],
                    [
                        "healthy": 0,
                        "item": "Mighty Leaf Tea"
                    ],
                    [
                        "healthy": 0,
                        "item": "Hot Cocoa"
                    ],
                    [
                        "healthy": 0,
                        "item": "Smoothies"
                    ],
                    [
                        "healthy": 0,
                        "item": "Pepsi Beverages"
                    ],
                    [
                        "healthy": 0,
                        "item": "Sushi"
                    ],
                    [
                        "healthy": 0,
                        "item": "and Grab-n-Go items."
                    ]
                ]
            ]
    ],
    "Ivy-Room" :
        [
            
            [
                "category"  : kMenuCategoryName,
                "items": [
                    [
                        "healthy": 0,
                        "item": "Pepsi Beverages"
                    ],
                    [
                        "healthy": 0,
                        "item": "Make Your Own Salads"
                    ],
                    [
                        "healthy": 0,
                        "item": "Breakfast Menu"
                    ],
                    [
                        "healthy": 0,
                        "item": "Burgers"
                    ],
                    [
                        "healthy": 0,
                        "item": "Fries"
                    ],
                    [
                        "healthy": 0,
                        "item": "Wraps"
                    ],
                    [
                        "healthy": 0,
                        "item": "Noodle Bowls"
                    ],
                    [
                        "healthy": 0,
                        "item": "Rice"
                    ],
                    [
                        "healthy": 0,
                        "item": "Quesadillas"
                    ],
                    [
                        "healthy": 0,
                        "item": "Burritos"
                    ],
                    [
                        "healthy": 0,
                        "item": "Tacos"
                    ],
                    [
                        "healthy": 0,
                        "item": "Grinders"
                    ],
                    [
                        "healthy": 0,
                        "item": "Pizza"
                    ],
                    [
                        "healthy": 0,
                        "item": "Garlic Knots"
                    ],
                    [
                        "healthy": 0,
                        "item": "Sushi"
                    ],
                    [
                        "healthy": 0,
                        "item": "and Grab-n-Go items."
                    ]
                ]
            ]
    ],
    "Marthas-Cafe" :
        [
            
            [
                "name"      : "Finger Lakes Specialty Coffees\nMighty Leaf Tea\nHot Cocoa\nPepsi Beverages\nBreakfast Menu\nHot and Cold Deli Sandwiches\nSoup\nChili\nBurritos\nSpinners\nTaco Salads\nQuesadillas\nNacho Platters\nSushi\nand Grab-n-Go items.",
                "category"  : kMenuCategoryName,
                "items": []
            ]
    ],
    "Mattins-Cafe" :
        [
            
            [
                "name"      : "Starbucks Specialty Coffees\nTazo Tea\nHot Cocoa\nPepsi Beverages\nBreakfast and Deli Sandwiches\nHot Sandwiches and Wraps\nSoup\nChili\nBurgers\nSubs\nSushi\nBaked Goods\nand Grab-n-Go items.",
                "category"  : kMenuCategoryName,
                "items": []
            ]
    ],
    "Rustys" :
        [
            
            [
                "name"      : "Starbucks Specialty Coffees\nTazo Tea\nHot Cocoa\nPepsi Beverages\nBaked Goods and Grab-n-Go items.",
                "category"  : kMenuCategoryName,
                "items": []
            ]
    ],
    "Synapsis-Cafe" :
        [
            
            [
                "name"      : "Finger Lakes Specialty Coffee\nMighty Leaf Tea\nHot Cocoa\nBubble Tea\nSmoothies\nPepsi Beverages\nHot and Cold Sandwiches\nSoup\nChili\nPizza\nPasta\nSalads\nFries\nSpanakopita\nBaked Goods\nand Grab-n-Go items.",
                "category"  : kMenuCategoryName,
                "items": []
            ]
    ],
    "Trillium" :
        [
            
            [
                "name"      : "Starbucks Coffees\nPepsi Beverages\nBreakfast Menu\nSalads\nDeli Sandwiches\nSoup\nChili\nPersonal Pizzas\nBurgers\nChicken Tenders\nQuesadillas\nBurritos\nTacos\nHot Wraps\nBok Choy\nFried Rice\nLo Mein\nBaked Goods\nand Grab-n-Go items.",
                "category"  : kMenuCategoryName,
                "items": []
            ]
    ]]

