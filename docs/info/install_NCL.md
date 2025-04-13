# Install NCL (6.6.2) on MacOS#

These notes describe installing NCL 6.6.2 on MacOS, see [https://www.ncl.ucar.edu/Download/macosx.shtml](https://www.ncl.ucar.edu/Download/macosx.shtml). This worked for installing NCL on an Apple MacBook Air M2 (2022).  It seems that Rosetta 2 takes care of running a version of the program that was compiled for an Intel processor, providing that gcc and gfortran (which provide libraries), were also created for Intel. 

### Install XQuartz

XQuartz is an X Window System that can be used to display NCL output on the screen.  Even if that never is done, it still needs to be installed.  XQuartz can be installed from [https://www.xquartz.org](https://www.xquartz.org)

### Download the binary 

See: [https://www.ncl.ucar.edu/Download/install\_from\_binary.shtml](https://www.ncl.ucar.edu/Download/install_from_binary.shtml)

- Browse to:  [https://www.ncl.ucar.edu/Download/list_of_binaries.shtml](https://www.ncl.ucar.edu/Download/list_of_binaries.shtml), and download:
- [https://www.earthsystemgrid.org/dataset/ncl.662.dap/file/ncl_ncarg-6.6.2-MacOS_10.14_64bit_gnu730.tar.gz](https://www.earthsystemgrid.org/dataset/ncl.662.dap/file/ncl_ncarg-6.6.2-MacOS_10.14_64bit_gnu730.tar.gz) 

### Extract files

Create a new folder: `/usr/local/ncl-6.6.2` by opening a Terminal window and entering `mkdir /usr/local/ncl-6.6.2`. On recent versions of macOS, making a destination folder for the binary may fail if attempted in a Terminal window (owing to the System Integrity Protection (SIP) thing in macOS), producing the following error:  `mkdir: /usr/local/ncl-6.6.2: Permission denied`.

The workaround is to use Finder to create the folder `/usr/local/ncl-6.6.2`, which will require authentication, and then do this (copy and paste to a Terminal window):

	cd /usr/local
	sudo chown -R $(whoami):staff *

Note: Finder can be made to show hidden files files and folders by typing in a Terminal window:

	defaults write com.apple.finder AppleShowAllFiles TRUE
	killall Finder

The NCL page indicates that the following approach will work for installing NCL:

    tar -zxf ~/Downloads/ncl_ncarg-6.6.2-MacOS_10.14_64bit_gnu730.tar -C /usr/local/ncl-6.6.2
    
If the `.tar` file didn't get decompressed (i.e. it ends in `.gz`) add `.gz` to the end of the file name.
    
### Set environment

Setting the environment has been troublesome.  On macOS Catalina, zsh has replaced bash as the default shell, and there seem to be no specific instructions for how to edit the environment files.  However, the following seems to work (for the Catalina and newer versions of MacOS:

Edit or create the file `/Users/bartlein/.zshenv` (used to be `/Users/bartlein/.bash_profile` before Catalina)

	export NCARG_ROOT=/usr/local/ncl-6.6.2  
	export PATH=$NCARG_ROOT/bin:$PATH  
	export LD_LIBRARY_PATH="${NCARG_ROOT}/lib:{LD_LIBRARY_PATH}"  
	ulimit -s  unlimited

NOTE:  You must logout, and log back in for this to take effect.
If you're running Catalina, put the contents above in in a file named `.zshenv` as opposed to `.bash_profile`.


### Install gcc and gfortran

The NCL page says:  "Download the appropriate version of gcc and gfortran from [http://hpc.sourceforge.net/](http://hpc.sourceforge.net/). If you download the "gcc-x.y.bin.tar.gz" file, you will get both gcc and gfortran."  
[(https://www.ncl.ucar.edu/Download/macosx.shtml)](https://www.ncl.ucar.edu/Download/macosx.shtml)

These are the instructions for installing on an **Intel Mac running Big Sur**, but they worked for installing gcc-7.3 on an Apple M2

- download `gcc-7.3-bin.tar.gz`
- cd to the `Downloads` folder. Then 
- open a Terminal window, and, while remaining in the `Downloads` folder, type
- `gunzip gcc-7.3-bin.tar.gz` (if your browser didn't do so already) and then type 
- `sudo tar -xvf gcc-7.3-bin.tar -C /`.
- Copy additional colormaps to `/usr/local/ncl-6.6.2/lib/ncarg/colormaps`

Note:  Sometimes this will corrupt an installation of `gcc` (and `gfortran`) and `netCDF` from Homebrew.  If so, reinstall `gcc` and `netcdf` from Homebrew.


### Test the installation

Typing the following in a command window should return the version number of NCL:

	ncl -V
	
The first time that's done, MacOS may respond: `“ncl” cannot be opened because the developer cannot be verified.`. Click `Cancel`, and go to `System Preferences > Security & Privacy > General` tab, at the bottom, click on `Allow Anyway`.  Then try again, and you will likely get the message `macOS cannot verify the developer of “ncl”. Are you sure you want to open it?`. Click `Open`.

You should see `6.6.2`

### Install Homebrew ###
 
Homebrew is at [https://brew.sh](https://brew.sh)

Paste the following (or whatever is current on the Homebrew web page) into a Terminal window, and follow the prompts.
	
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	
Installation can take a little while, and may produce some warnings that are usually benign.

Homebrew might ask you to run the following commands after installation is completed:

	(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/bartlein/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

The path (displayed by typing `echo $PATH`) should look like: 

>/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/ncl-6.6.2/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/ncl-6.6.2/bin

It has sometimes been necessary to add an additional environment file to the user home directory.  Create the file `.zprofile` with the contents:
	
	export NCARG_ROOT=/usr/local/ncl-6.6.2  
	export PATH=$NCARG_ROOT/bin:$PATH  
	export LD_LIBRARY_PATH="${NCARG_ROOT}/lib:{LD_LIBRARY_PATH}"  
	ulimit -s  unlimited
	eval $(/opt/homebrew/bin/brew shellenv)

If already installed, update Homebrew  (see [https://github.com/Homebrew/brew/blob/master/docs/FAQ.md](https://github.com/Homebrew/brew/blob/master/docs/FAQ.md)): 

	brew update
	brew upgrade
	brew cleanup
	

### Install netCDF ###

See [https://formulae.brew.sh/formula/netcdf](https://formulae.brew.sh/formula/netcdf).  At the time of this writing (27 Aug 2023), the current version was `4.9.2`.

	brew install netcdf
 
There will be a number of additional dependencies that will be installed as well, as will be true for `CDO` and `NCO` below. 

If netCDF is already installed, try upgrading:

	brew upgrade netcdf

If the currently installed version is the most recent one, you’ll get an error like:

	Warning: netcdf 4.9.2 is already installed and up-to-date.
	
Check to see if netCDF has been installed:

	ncdump

The last line of the response should return the current version; here it's `4.9.2`

Make a shortcut for getting a headers-only `ncdump` of a netCDF file.  First, find the exact folder in which netCDF was installed, something like: `/opt/homebrew/Cellar/netcdf/4.9.2_1/`.  (4.9.2 is the version of netCDF, and "_1" indicates that it's the first revised Homebrew version.) You will probably have to to this by hand.

Create a file simply called `ncd` (no extension) containing:

	#! /bin/bash
	pwd
	/opt/homebrew/Cellar/netcdf/4.9.0_1/bin/ncdump -c $1

Copy or move this file to `/usr/local/bin/`  (Note that the specific reference to the netCDF library version (`4.9.2_1`) will have to be edited to match the current version of netCDF when netCDF is upgraded.)

Make the file executable: 

	sudo chmod +x ncd
	
Then typing, e.g. `ncd myfile.nc` in a Terminal window will `ncdump` the headers (attributes, etc.) and coordinate variable information (lon, lat, time).

### CDO ###

See [https://code.mpimet.mpg.de/projects/cdo/wiki/MacOS_Platform](https://code.mpimet.mpg.de/projects/cdo/wiki/MacOS_Platform)

CDO can be installed by typing:
	
	brew install cdo

Check the installation (note that there are two hyphens before "version"):

	cdo --version
	
Note the double hyphen.  CDO can be updated as follows:

	brew upgrade cdo

### NCO ###

See:  [http://nco.sourceforge.net](http://nco.sourceforge.net)

NCO can be installed as follows:

	brew install nco

Check the installation (note that there are two hyphens before "version"):

	ncatted --version 

Note the double hyphen, and that it's one of the individuals command-line tools in NCO that is being queried for its version number.  NCO can be updated as follows:

	brew update eco


### Panoply ###

Panoply is a handy viewer for netCDF files (and also a good check that a new file conforms to common standards like the Climate Forecast (CF) standards).  It can be downloaded from:

	<https://www.giss.nasa.gov/tools/panoply/>

If Panoply pops up a dialog saying that a Java environment must be installed, one can be obtained at Oracle. Here are the instructions, and the download page (as of 26 Feb 2023):

	<https://docs.oracle.com/en/java/javase/11/install/installation-jdk-macos.html>
	<https://www.oracle.com/java/technologies/downloads/#jdk19-mac>


`
