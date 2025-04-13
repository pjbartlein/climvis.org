## Installing SublimeText for NCL##

### Sublime Text ###

Install Sublime Text 3 from here:  [http://www.sublimetext.com](http://www.sublimetext.com)

Install Package Control (for installing subsequent add-ons, etc.)

- Tools > Install Package Control
- restart Sublime Text

Install a package (e.g. MinimalFortran for Fortran code highlighting)

- Tools > Command Palette
- type "Package", choose Install Package
- type "ModernFortran", click on entry or hit Enter

(Can also do this through Sublime Text > Preferences > Package Control)

Install Print to HTML for printing through the browser:

- Tools > Command Palette
- type "Package", choose "Install Package"
- type "PrintToHTML", click on entry or hit Enter

To print:	File > Print...

### Install NCL Sublime Text Editor Enhancement ##

See [http://www.ncl.ucar.edu/Applications/editor.shtml](http://www.ncl.ucar.edu/Applications/editor.shtml)

Here's the link to the Sublime Text package:  [https://packagecontrol.io/packages/NCL](https://packagecontrol.io/packages/NCL), which simply describes the installation using Package Control

- Tools > Command Palette
- type "Package", choose "Install Package"
- type "NCL", click on entry or hit Enter

Once installed, use "Info" in Finder on a .ncl file to set Sublime Text as the app for opening .ncl files.  Double-clicking on a .ncl file opens it in Sublime Text, Command-B builds a file (runs NCL), and Tools > Snippets provides a few basic NCL code blocks.

### Mac Classic theme ###

Download the package of "Color Scheme - Legacy" [[here]](https://github.com/SublimeText/LegacyColorSchemes) 

Copy the downloaded file to: `/Users/bartlein/Library/Application Support/Sublime Text/Packages/User//Theme-Default`

Or, from the Sublime Text menu: Preferences -> Browse Packages -> Inside the folder that pops up, create a subfolder: Mac Classic.tmTheme -> Drop the file Mac Classic.tmTheme in there.

Restart Sublime Text and apply the Mac Classic theme `Sublime Text > Settings > Select Color Theme > Mac Classic`
