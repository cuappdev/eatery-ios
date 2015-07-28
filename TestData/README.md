#TestData

This directory contains calendar test data to eliminate the need for network requests while developing.  To use it, drop the contents of the ./Documents directory into  
>Users/ericpel28/Library/Developer/CoreSimulator/Devices/{ crazy-long-simulator-id }/data/Containers/Data/Application/{ other-crazy-long-simulator-id }/Documents

To use a test menu, uncomment the code in EatNowTableViewController in `-didSelectRowAtIndexPath:`