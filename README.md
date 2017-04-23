# Guardian-IOS [![Build Status](https://travis-ci.org/fhboswell/Guardian-IOS.svg?branch=master)](https://travis-ci.org/fhboswell/Guardian-IOS)

Implementation details:
* Written in Swift
* Token Auth (using Devise server side)
* Realtime Updates using Action Cable
* Served by the Guardian website's API 
* CoreData
* Keychain
* Travis CI testing

Frameworks added with Carthage:
* ActionCableclient
* Starscream
* JSONSwifty


To Demo Action Cable 
1. Open a browser window and the app
2. Create an account in the browser
3. Log into the same account on both devices
4. Create a group
5. Navigate into the same group on both devices
6. Create some Individuals
7. In the row of the individuals there is a button "Change Status"
8. Click this button and observe that it instantly updates on the other device
9. This works across Computers and IOS devices



Note, this product is still in development
