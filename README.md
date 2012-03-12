# fb-canvas-rails

This is a sample Facebook Canvas App built with Ruby on Rails 3.2. It demonstrates workarounds, fixes and hacks to solve some of the most frequently encountered problems with Facebook Canvas applications.

## Features

* Fixes broken back button in IFrame (uses PushState for smart browsers, and window.top.location for IE)
* Handles disabled 3rd party cookies gracefully (ie: maintain session even when cookies are disabled)
* Properly sets the P3P header for Internet Explorer
* Handles Facebook's signed_request POST transparently
* OAuth Authentication
* Sends CSRF token with AJAX requests
* CJAX script to for PushState. CJAX uses History.js under the hood and was heavily influenced by History.js and PJAX.

## Demo

You can see this code in action at http://apps.facebook.com/fb-canvas-rails
