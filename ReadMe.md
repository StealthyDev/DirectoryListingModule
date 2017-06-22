# DirectoryListingModule for IIS
Nice looking directory listing in IIS, replacing default DirectoryListingModule.

## Credits
Original author: Mike Volodarsky
Source: http://mvolo.com/get-nice-looking-directory-listings-for-your-iis-website-with-directorylistingmodule/

## How to use in IIS 7.5 or above (might work in IIS7)
* Install IIS
  * Security - enable Windows Authentication
  * Common HTTP - enable WebDav publishing
  * Install ASP.net
* At the site level, disable all authentication methods except Windows Authentication
* Change the IIS DefaultAppPool identity from ApplicationPoolIdentity to LocalSystem
* Add an IIS virtual directory pointing to a local physical path. 
* Enable directory listing in virtual directory