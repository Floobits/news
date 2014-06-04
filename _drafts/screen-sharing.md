Screen sharing on floobits

* Screen sharing is really useful
	* Floobits lets you do lots of cool things with text editors and on the command line, but sometimes you want share other things
		* debugger output in intellij
		* documentation on the web
		* demo desktop application
		* show performance stats in a GUI application like Activity Monitor
		* Share profiling information in Chrome’s Web Inspector
	* Tried Screen Hero
		* Pros
			* Fellow YC company we like
			* Very easy to get started 
			* Can use our @floobits emails, no Google account requied, but does require registration
		   * Cons
			* Found remote being able to manipulate things weird
			* If remote user had the window focused couldn’t do stuff like copy and paste
			* Lagged quite a bit for remote, couldn’t follow switching screens or scrolling quickly
				* There are probably some settings we could tweak to make this better
			   * Requires an additional app
			* Not built into Floobits, not deployable to enterprise customers
	* Tried Hangouts
		* Pros
			* Let’s you share screens
			   * lets you build an app to run Floobits in an iframe
			* Has lots of cool features not yet easy to build with webrtc
				* remote audio levels
					* link to bug on chromium
		* cons
			* requires Google account, 
				* not good for enterprise our behind the enter
				* people that don’t want to use Google+ 
				* people that don’t have a Google account
			* Not built into Floobits, not deployable to enterprise customers
* Floobits lets you share screens
	* Show screenshot
	* Pros
		* Built into Floobits, deployable to enterprise
		* Customise it to what we want and need
	* Cons
		* only works in chrome
		* requires extension
		* still beta
		* can eat lots of CPU, especially when sharing big screens
* We share screens using webrtc
	* we use getUserMedia to get it
	* this stuff is not well documented
	* examples and trying hard and failing lots to get it to work
	* Can hack sdp to reduce bandwidth for webrtc, but for sharing screenshots, details are nice
* We used to get screen access via getUserMedia on the drive by web
	* Used *screen*
	* Could only share entire Desktop
	* required a flag in chrome settings
	* turned off without warning
	* we really missed it when it broke
* Now we use an extension
	* Still uses getUserMedia with desktop
	* chooseDesktopMedia
	* Lets you pick windows ore the entire screen, just like Hangouts
	* makes it easier to install
		* use inline installation
			* events
	   * content scripts
	* background.js
* You should use it.
	* You can share your webcam too, audio stream is separate
	* Show a small screenshot of the sidebar with the webrtc popup visible