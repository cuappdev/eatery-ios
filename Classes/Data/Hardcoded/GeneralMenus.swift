//
//  Calendars.swift
//  Eatery
//
//  Created by Eric Appel on 5/5/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

private let kMenuNotAvailable = "Menu not available."

let kEateryGeneralMenus: [String : JSON] =
[
"amit_bhatia_libe_cafe" :
[
    "general"   : [
        [
            "name"      : "Starbucks Specialty Coffee, Tazo Tea, Hot Cocoa, Frappuccino, Pepsi Beverages, Smoothies, Baked Goods, Sushi, and Grab-n-Go items.",
            "category"  : "Menu"
        ]
    ]
],
"atrium_cafe" :
[
    "general"   : [
        [
            "name"      : "Starbucks Specialty Coffee, Tazo Tea, Hot Cocoa, Pepsi Beverages, Pizza, Dim Sum, Salads, Soups, Chili, Hot and Cold Specialty Sandwiches, Build Your Own Sandwich, Sushi, and Grab-n-Go items.",
            "category"  : "Menu"
        ]
    ]
],
"bear_necessities" :
[
    "general"   : [
        [
            "name"      : "Starbucks Coffee, Tazo Tea, Hot Cocoa, Pepsi Beverages, Breakfast Menu, Deli Sandwiches, Burgers, Hot Dogs, Wings, Pizza, Calzones, Soup, Chili, Fries, Mozzarella Sticks, Onion Petals, and Grab-n-Go items.",
            "category"  : "Menu"
        ], [
            "name"      : "During the summer, the Bear Necessities deli and salad counter is closed, and the grill closes at 2pm Monday through Friday. Pizza and calzones are available throughout open hours, and there are FreshTake sandwiches and salads in the cooler.",
            "category"  : "Special Note"
        ]
    ]
],
"bears_den" :
[
    "general"   : [
        [
            "name"      : "New York Style Pizza, Ivy Room Grinders, garlic knots, Pepsi beverages, beer and wine.",
            "category"  : "Menu"
        ]
    ]
],
"big_red_barn" :
[
    "general"   : [
        [
            "name"      : "Finger Lakes Coffee, Mighty Leaf Tea, Pepsi Beverages, Salads, Breakfast Menu, Pasta, Pizza, Deli and Specialty Sandwiches, Subs and Grab-n-Go items.",
            "category"  : "Menu"
        ]
    ]
],
"cafe_jennie" :
[
    "general"   : [
        [
            "name"      : "Join us in the morning for Steel Cut Oatmeal, Chobani Greek Style Yogurt, or Chorizo or a Vegetable Frittata Bagel Sandwich. Pop by at lunchtime for one of our creative new sandwiches and wraps, like Beef Brisket, Roasted Vegetable Focaccia, or Thai Chicken. Or visit any time for brewed coffee or tea or an espresso beverage made with Peet's Coffee.",
            "category"  : "Menu"
        ]
    ]
],
"carols_cafe" :
[
    "general"   : [
        [
            "name"      : "Starbucks Specialty Coffees, Tazo Tea, Hot Cocoa, Frappuccino, Smoothies, Pepsi Beverages, Baked Goods, Sushi, and Grab-n-Go items.",
            "category"  : "Menu"
        ]
    ]
],
"cascadeli" :
[
    "general"   : [
        [
            "name"      : kMenuNotAvailable,
            "category"  : "Menu"
        ]
    ]
],
"cornell_dairy_bar" :
[
    "general"   : [
        [
            "name"      : "Finger Lakes Coffee Roasters Specialty Coffee, Mighty Leaf Tea, Hot Cocoa, Frozen Lattes and Mochas, Pepsi Beverages, Hot & Cold Sandwiches, Soups, and Grab-n-Go items. Order ice cream cupcakes and ice cream sandwiches for your events 48 hours in advance!",
            "category"  : "Menu"
        ], [
            "name"      : "Sweet CORNell\nBavarian Raspberry Fudge\nCornelia's Dark Secret\nPeanut Butter Mini\nFrench Vanilla\nEzra's Morning Cup\nTriple Play Chocolate\nMint Chocolate Cookie\nVanilla\nChocolate\nCaramel Cubed\nBlack Raspberry\nBear Tracks\nCookies & Cream\nCaramel Turtle Sundae\nMint Chocolate Chip\nStrawberry\nBoorange Chip\nFrozen Four Ezra\nCookie Dough Dream\nThanks for understanding if we're temporarily out of a particular flavor, or need to make substitutions. Sometimes people eat a lot of ice cream, and we just run out of something!",
            "category"  : "Current Cornell Dairy ice cream flavors"
        ]
    ]
],
"goldies" :
[
    "general"   : [
        [
            "name"      : "Starbucks Specialty Coffees, Tazo Tea, Hot Cocoa, Frappuccino, Pepsi Beverages, Soup, Breakfast Sandwiches, Deli and Signature Sandwiches, Sushi, Baked Goods, and Grab-n-Go items.",
            "category"  : "Menu"
        ]
    ]
],
"green_dragon" :
[
    "general"   : [
        [
            "name"      : "Finger Lakes Specialty Coffees, Mighty Leaf Tea, Hot Cocoa, Smoothies, Pepsi Beverages, Sushi, and Grab-n-Go items.",
            "category"  : "Menu"
        ]
    ]
],
"ivy_room" :
[
    "general"   : [
        [
            "name"      : "Pepsi Beverages, Make Your Own Salads, Breakfast Menu, Burgers, Fries, Wraps, Noodle Bowls, Rice, Quesadillas, Burritos, Tacos, Grinders, Pizza, Garlic Knots, Sushi, and Grab-n-Go items.",
            "category"  : "Menu"
        ]
    ]
],
"jansens_market" :
[
    "general"   : [
        [
            "name"      : kMenuNotAvailable,
            "category"  : "Menu"
        ]
    ]
],
"marthas_cafe" :
[
    "general"   : [
        [
            "name"      : "Finger Lakes Specialty Coffees, Mighty Leaf Tea, Hot Cocoa, Pepsi Beverages, Breakfast Menu, Hot and Cold Deli Sandwiches, Soup, Chili, Burritos, Spinners, Taco Salads, Quesadillas, Nacho Platters, Sushi, and Grab-n-Go items.",
            "category"  : "Menu"
        ]
    ]
],
"mattins_cafe" :
[
    "general"   : [
        [
            "name"      : "Starbucks Specialty Coffees, Tazo Tea, Hot Cocoa, Pepsi Beverages, Breakfast and Deli Sandwiches, Hot Sandwiches and Wraps, Soup, Chili, Burgers, Subs, Sushi, Baked Goods, and Grab-n-Go items.",
            "category"  : "Menu"
        ]
    ]
],
"rustys" :
[
    "general"   : [
        [
            "name"      : "Starbucks Specialty Coffees, Tazo Tea, Hot Cocoa, Pepsi Beverages, Baked Goods and Grab-n-Go items.",
            "category"  : "Menu"
        ]
    ]
],
"synapsis_cafe" :
[
    "general"   : [
        [
            "name"      : "Finger Lakes Specialty Coffee, Mighty Leaf Tea, Hot Cocoa, Bubble Tea, Smoothies, Pepsi Beverages, Hot and Cold Sandwiches, Soup, Chili, Pizza, Pasta, Salads, Fries, Spanakopita, Baked Goods, and Grab-n-Go items.",
            "category"  : "Menu"
        ]
    ]
],
"trillium" :
[
    "general"   : [
        [
            "name"      : "Starbucks Coffees, Pepsi Beverages, Breakfast Menu, Salads, Deli Sandwiches, Soup, Chili, Personal Pizzas, Burgers, Chicken Tenders, Quesadillas, Burritos, Tacos, Hot Wraps, Bok Choy, Fried Rice, Lo Mein, Baked Goods, and Grab-n-Go items.",
            "category"  : "Menu"
        ]
    ]
]]


let kEmptyMenuJSON: JSON = [
    "general"   : [
        [
            "name"      : kMenuNotAvailable,
            "category"  : "Menu"
        ]
    ]
]
