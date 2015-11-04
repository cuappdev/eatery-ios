<img src=Github-Assets/eatery_icon.png width=400 />  

Eatery is the first app from [CUAppDev](http://cuappdev.org), a project team at Cornell University.  It provides an easy and accessible way to browse the hours and menus of the dining locations on campus.

<img src=Github-Assets/home_screen.png width=350 />
<img src=Github-Assets/detail_screen.png width=350 />

## Supported Eateries
* 104west
* amit_bhatia_libe_cafe
* atrium_cafe
* bear_necessities
* bears_den
* becker_house_dining_room
* big_red_barn
* cafe_jennie
* carols_cafe
* cascadeli
* cook_house_dining_room
* cornell_dairy_bar
* goldies
* green_dragon
* ivy_room
* jansens_dining_room_bethe_house
* jansens_market
* keeton_house_dining_room
* marthas_cafe
* mattins_cafe
* north_star
* okenshields
* risley_dining
* robert_purcell_marketplace_eatery
* rose_house_dining_room
* rustys
* synapsis_cafe
* trillium


#Development

## Dependency management
Currently we use four third party libraries (found in the `vendor` directory).  For now, we will just copy and paste them into our project to update.  This obviously isn't very scalable but for the short-term, it will drastically decrease the number of build errors in development.  

[UPDATE] We now use Cocoapods.  Run `pod install` before opening xcode and make sure you use the .xcworkspace from now on.  

When cloning the current version, call `git clone --recursive https://github.com/cuappdev/eatery.git`

If you already have the project installed, call `git submodule update --init --recursive`

## Architecture
[coming soon]
