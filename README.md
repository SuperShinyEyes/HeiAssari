# HeiAssari
Hacky A+ notification app for Aalto TAs

## Introduction

### What is it?
It's a simple notification app **for Aalto University Teaching Assistants(TA)** who work on [A+ system](https://plus.cs.hut.fi/). It notifies you when there's a new student in the queue(Neuvontajono).

### Who am I?
My name is Seyoung Park and I'm a CS undergradute at Aalto University. I'm working as a TA on CS-A1141 Data Structure and Algorithms course. If the code looks ugly please forgive me. I made this app for just for my sake. In fact I made this during my TA shift when students were not asking any question. So code quality wasn't on my top priority. You can find me at [seyoung.xyz](http://seyoung.xyz/).

### How does it work?
First, you have to manually go to *your-course/Neuvontajono/Jonon hallinta/your-group*. Once you're there the app will read the html page on Neuvontajono periodically(3~5 sec.), and when there's a new student in the queue it notifies you. The app works in the background(homescreen, switch app, lockscreen) too however, in a hackish way by playing the silent mp3 repeatedly. This is the easiest way not to be suspended by iOS. Though, it is not how you are supposed to design the app so don't even think about pushing this kind of mechanism to AppStore. 😉

### Security
It is 100% secure. I DO NOT authenticate you on behalf of you. You authenticate yourself on iOS native framework, [WKWebView](https://developer.apple.com/reference/webkit/wkwebview), which is like a web browser Safari. Therefore your account information is ONLY going to A+ server.

### Why?
Because we're all too lazy to check the system manually....

### !Attention!
Because the app is playing the silent mp3, **remember to manually terminate the app** after your shift is over. Otherwise the app will never get terminated.


## Installation

### Environment
* iOS 10
* [Xcode 8](https://developer.apple.com/xcode/)

You need to install via Xcode and you need an Apple ID for it. Sorry about that...😥 Xcode doesn't provide *apk* files like in Android.

## Credits
Icon and back button image by [Freepik](http://www.freepik.com)
