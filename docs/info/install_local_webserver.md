# Install a local web server #

Seems to work on MacOS Monterey and Ventura

### Edit the Apache (web server) configuration file ###

Browse to `Macintosh HD/etc/apache2/httpd.conf` and make a backup of this file by copying it somewhere.  

Edit this file in Sublime text.  Browse to the bottom and add the following:

	<VirtualHost *:80>
	    <Directory /Library/WebServer/Documents/>
	        Options Indexes
	        IndexOptions FancyIndexing
	        IndexOptions NameWidth=*
	    </Directory>
	</VirtualHost>

Save the file.  You'll probably have to enter your password. (see [https://tonyteaches.tech/allow-apache-directory-listing/](https://tonyteaches.tech/allow-apache-directory-listing/))

### Turn on the web server ###

Open a terminal window and type

	sudo apachectl start

and enter your password.  (See [https://www.maketecheasier.com/setup-local-web-server-all-platforms/](https://www.maketecheasier.com/setup-local-web-server-all-platforms/))

### Copy content ###

The root folder for the web server, equivalent to `public_html` on many systems is `/Library/WebServer/Documents/`.  Copy the web page files here.

### Browse the web page ###

Open a browser, and type `localhost` in the address bar.  You can get a browsable file listing of the files in the `/Library/WebServer/Documents/` folder by typing `localhost/content/` in the address bar.