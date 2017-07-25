# discourse-windowslive-auth

This plugin utilizes OAuth 2.0 to connect to the Windows Live service (Live 
Connect) so that users may authenticate with their Microsoft Accounts
directly with Discourse. This is useful for anyone wishing to authenticate
with Windows Live without the headache of implementing their own plugin.

This plugin is heavily based upon the 
[discourse-oauth2-basic](https://github.com/discourse/discourse-oauth2-basic) 
plugin. A great many thanks go out to developer(s) for the codebase! Couldn't 
have done it without you.

__Note: I do not know Ruby/RoR and this is my very first dabbling with such.
Things have surely been done poorly and I apologize for that ahead of time.__

## Features

* Allow users to signup/login to Discourse via their Microsoft Accounts
* Imports the email address associated with their Microsoft Account
* Imports their name and generates a username
* Downloads their avatar from their Microsoft account (does not overwrite Gravatar)
* Allows editing of imported info before account creation*  
\* _except avatar and email if __email verified__ setting is enabled_
* Detailed log info (toggleable)
* Customizable button text

## Requirements

1. A working Discourse installation through Docker [[reference](https://github.com/discourse/discourse/blob/master/docs/INSTALL-cloud.md)]
2. SSL (callback URLs must use SSL - you can't even add them if they don't!)

## Installation and Setup

### Installing the Plugin in Discourse

Install the plugin by adding this GitHub repo to your `app.yml` file in your
after_code hooks (be __very__ careful about spacing - YAML has no mercy): 
   
`- git clone https://github.com/coryjreid/discourse-windowslive-auth.git`

Now run `cd /var/discourse && sudo ./launcher rebuild app`.

You need an application with Microsoft to allow authentication! If you don't 
have one yet you can easily register a new application at the Microsoft 
[Application Registration Portal](https://apps.dev.microsoft.com/). You need 
a Microsoft Account to do this. Do this while your Discourse rebuilds!

### Creating a Windows Live Application

1. Create a new application, unchecking __Guided Setup__
2. Save your __Application Id__ to a temporary place
3. Click on __Generate New Password__ under Application Secrets
4. Save your one-time-displayed __Password__ in the same manner as your Application Id  
   (If you accidentally dismiss the modal before saving just delete and make a 
   new one)
5. Click on __Add Platform__ and select __Web__
6. Check __Allow Implicit Flow__
7. Add the following url to __Redirect URLs__ and __Logout URL__  
   `https://YOUR.DISCOURSE.COM/auth/windows_live/callback`  
   __^^^^ this is not a joke__
8. Check __Live SDK support__ under Advanced Options
9. Fill in the remaining information as you see fit and __Save__ your app

### Configuring the Plugin

Remember that information we saved when creating a Windows Live application? Now we need it! Assuming your Discourse has finished rebuilding and is online, login and access the admin control panel and navigate to `Settings > Login` and scroll down to find your Windows Live settings (tip: filter using "windows live" in the search box).

1. Check the box to enable login with Windows Live
2. Copy and paste your Application Id into the appropriate field
3. Copy and paste your Application Secret (Password) into the appropriate field
4. Logout to see your plugin in action!

## Contributing / Helping

* Create a Pull Request with a new translation
* Log Issues
* Submit Pull Requests to help resolve issues or add new features


## License

MIT
