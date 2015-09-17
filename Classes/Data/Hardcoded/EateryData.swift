//
//  GeneralMenus.swift
//  Eatery
//
//  Created by Eric Appel on 7/21/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

let kEateryData: [String : JSON] =
[
"104west" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/vlpa2hk9677m9bcbh6n2dtpn7k%40group.calendar.google.com/public/basic.ics",
    "coordinates"   : [
        "latitude"      : 42.4442660,
        "longitude"     : -76.4875983
    ],
    "payment"       : "BRB,cash,swipe",
    "name"          : "104 West! (Kosher Dining)",
    "type"          : "Swipes"
],
"amit_bhatia_libe_cafe" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/g1pfs9edl1ks5o2dbc58e7fhm8%40group.calendar.google.com/public/basic.ics",
    "coordinates"   : [
        "latitude"      : 42.448019,
        "longitude"     : -76.484499
    ],
    "location"       : "Olin Library, Central Campus",
    "payment"       : "BRB,cash",
    "name"          : "Amit Bhatia Libe Café",
    "type"          : "BRB"
],
"atrium_cafe" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/9g3c81c0p2loacsbvrjj5o371c%40group.calendar.google.com/public/basic.ics",
    "coordinates"   : [
        "latitude"      : 42.446071,
        "longitude"     : -76.483061
    ],
    "location"       : "Sage Hall, Central Campus",
    "payment"       : "BRB,cash",
    "name"          : "Atrium Café",
    "type"          : "BRB"
],
"bear_necessities" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/h319a8fk4b5lv0644ebkskhha8%40group.calendar.google.com/public/basic.ics",
    "coordinates"   : [
        "latitude"      : 42.455935,
        "longitude"     : -76.477911
    ],
    "location"      : "Robert Purcell Community Center, North Campus",
    "payment"       : "BRB,cash",
    "name"          : "Bear Necessities",
    "type"          : "BRB"
],
"bears_den" :
[
    "icalendar"       : "https://www.google.com/calendar/ical/9pkqrt6elrngarcrf1s4vvdqf4%40group.calendar.google.com/public/basic.ics",
    "coordinates"   : [
        "latitude"      : 42.446372,
        "longitude"     : -76.485786
    ],
    "location"       : "Ivy Room, Willard Straight Hall, Central Campus",
    "payment"       : "BRB,cash",
    "name"          : "Bear's Den Café",
    "type"          : "BRB"
],
"becker_house_dining_room" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/di2s9rofto7m8innt5e8vftl0o%40group.calendar.google.com/public/basic.ics",
    "coordinates"   : [
        "latitude"      : 42.448306,
        "longitude"     : -76.489574
    ],
    "payment"       : "BRB,cash,swipe",
    "name"          : "Becker House Dining Room",
    "type"          : "Swipes"
],
"big_red_barn" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/u1kmovdep2qlmr86io8h4p3ee8%40group.calendar.google.com/public/basic.ics",
    "coordinates"   : [
        "latitude"      : 42.448526,
        "longitude"     : -76.48098
    ],
    "location"       : "Big Red Barn, Central Campus",
    "payment"       : "cash",
    "name"       : "Big Red Barn",
    "type"          : "BRB"
],
"cafe_jennie" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/geron0aq1ooj7jugmcmdc2s2cc%40group.calendar.google.com/public/basic.ics",
    "coordinates"   : [
        "latitude"      : 42.446851,
        "longitude"     : -76.484376
    ],
    "location"       : "The Cornell Store, Upper Level near the Skylight, Central Campus",
    "payment"       : "BRB,cash",
    "name"          : "Café Jennie",
    "type"          : "BRB"
],
"carols_cafe" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/05r2nhfjbnknmsccgd6u8dij0g%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.453117,
        "longitude"     : -76.479864
    ],
    "location"      : "Balch Hall, North Campus",
    "payment"       : "BRB,cash",
    "name"          : "Carol's Café",
    "type"          : "BRB"
],
"cascadeli" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/ju94n6trv0ccoqcnd5u7otle50%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.446689,
        "longitude"     : -76.485679
    ],
    "payment"       : "BRB,cash",
    "name"          : "Cascadeli",
    "type"          : "BRB"
],
"cook_house_dining_room" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/27hli58rto1hpf15m3sbe54sak%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.448940,
        "longitude"     : -76.489560
    ],
    "payment"       : "BRB,cash,swipe",
    "name"          : "Cook House Dining Room",
    "type"          : "Swipes"
],
"cornell_dairy_bar" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/prvu4v0nr4eu94mqu9q7busa6g%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.447554,
        "longitude"     : -76.471048
    ],
    "location"       : "Stocking Hall, Central Campus",
    "payment"       : "cash",
    "name"          : "Cornell Dairy Bar",
    "type"          : "BRB"
],
"goldies" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/kb9ce5jj2f6oli3c90tc7j6peo%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.450394,
        "longitude"     : -76.482096
    ],
    "location"       : "Physical Sciences, Central Campus",
    "payment"       : "BRB,cash",
    "name"          : "Goldies",
    "type"          : "BRB"
],
"green_dragon" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/7sii70faon9ta2vpoehr69415s%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.450948,
        "longitude"     : -76.484456
    ],
    "location"       : "Sibley, Central Campus",
    "payment"       : "BRB,cash",
    "name"          : "Green Dragon",
    "type"          : "BRB"
],
"ivy_room" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/ve9kl6pq8esjfqbhg03qnjtgjg%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.446372,
        "longitude"     : -76.485786
    ],
    "location"       : "Willard Straight Hall, Central Campus",
    "payment"       : "BRB,cash",
    "name"          : "Ivy Room",
    "type"          : "BRB"
],
"jansens_dining_room_bethe_house" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/h0nfohf0d90ot1rmukjphj7ajc%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.447116,
        "longitude"     : -76.48864
    ],
    "payment"       : "BRB,cash,swipe",
    "name"          : "Jansen's Dining Room (Bethe House)",
    "type"          : "Swipes"
],
"jansens_market" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/0dqnc6l2mt25okch8nimsnojhg%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.446325,
        "longitude"     : -76.487932
    ],
    "payment"       : "BRB,cash",
    "name"          : "Jansen's Market",
    "type"          : "BRB"
],
"keeton_house_dining_room" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/ekd72jfc2qai617oloa2b0ibp0%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.446803,
        "longitude"     : -76.489478
    ],
    "payment"       : "BRB,cash,swipe",
    "name"          : "Keeton House Dining Room",
    "type"          : "Swipes"
],
"marthas_cafe" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/sperf092mrbt796rr36toeqrus%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.449903,
        "longitude"     : -76.479092
    ],
    "location"      : "MVR, Central Campus",
    "payment"       : "BRB,cash",
    "name"          : "Martha's Cafe",
    "type"          : "BRB"
],
"mattins_cafe" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/1qman2n728pqjuq5ntaoofc7v0%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.444805,
        "longitude"     : -76.482589
    ],
    "location"      : "Duffield Hall, Central Campus",
    "payment"       : "BRB,cash",
    "name": "Mattin's Cafe",
    "type"          : "BRB"
],
"north_star" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/ecbhqf3ibeei09dds91viod5g8%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.453449,
        "longitude"     : -76.473503
    ],
    "payment"       : "BRB,cash,swipe",
    "name"          : "North Star",
    "type"          : "Swipes"
],
"okenshields" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/3hku0mr66kapq1lh8fakug9kko%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.4464907,
        "longitude"     : -76.4856783
    ],
    "payment"       : "BRB,cash,swipe",
    "name"          : "Okenshields",
    "type"          : "Swipes"
],
"risley_dining" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/hq98btd396f3077p88d30c84fs%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.453239,
        "longitude"     : -76.482080
    ],
    "payment"       : "BRB,cash,swipe",
    "name"          : "Risley Dining Hall",
    "type"          : "Swipes"
],
"robert_purcell_marketplace_eatery" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/32uglqeiqfo9edhpp4tka8oqsc%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.456010,
        "longitude"     : -76.477628
    ],
    "payment"       : "BRB,cash,swipe",
    "name"          : "Robert Purcell Marketplace Eatery",
    "type"          : "Swipes"
],
"rose_house_dining_room" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/mo4mqfpe88ucqaer728ovfei18%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.447961,
        "longitude"     : -76.488796
    ],
    "payment"       : "BRB,cash,swipe",
    "name"          : "Rose House Dining Room",
    "type"          : "Swipes"
],
"rustys" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/sqp9nd9rt727fm7v2sgmfelkps%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.447116,
        "longitude"     : -76.482031
    ],
    "location"      : "Uris Hall, Central Campus",
    "payment"       : "BRB,cash",
    "name"          : "Rusty's",
    "type"          : "BRB"
],
"synapsis_cafe" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/h8v5tm5eknsvhgm65bv30dqj0o%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.446863,
        "longitude"     : -76.477311
    ],
    "location"      : "Weill Hall, Central Campus",
    "payment"       : "BRB,cash",
    "name"          : "Synapsis Cafe",
    "type"          : "BRB"
],
"trillium" :
[
    "icalendar"     : "https://www.google.com/calendar/ical/i8v43jd76mugc62voucp4dqn9s%40group.calendar.google.com/public/basic.ics",
    "coordinates" : [
        "latitude"      : 42.4470972,
        "longitude"     : -76.4821258
    ],
    "location"      : "Kennedy Hall, Central Campus",
    "payment"       : "BRB,cash",
    "name"          : "Trillium",
    "type"          : "BRB"
]]
