# Running gfortran with netCDF using Eclipse on MacOS -- Apple Silicon#

## Install Homebrew ##
 
Homebrew is at [https://brew.sh](https://brew.sh)

Paste the following (or whatever is current on the Homebrew web page) into a Terminal window.

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	
If already installed, update Homebrew  (see [https://github.com/Homebrew/brew/blob/master/docs/FAQ.md](https://github.com/Homebrew/brew/blob/master/docs/FAQ.md)): 

	brew update
	brew upgrade
	brew cleanup

## Install gcc (including gfortran) ##

The GCC compilers are at [https://formulae.brew.sh/formula/gcc#default](https://formulae.brew.sh/formula/gcc#default)

If a previous version of netCDF from Homebrew didn't install gcc as a dependency, or if netCDF was already installed, but not gcc, then install gcc as follows: 

	brew install gcc

The current version (as of 1 May 2029) is `13.1.0`.  Note that a number of dependency packages will also be installed.

Homebrew will select the right version (e.g. Big Sur, Monterey, or Ventura)

If gcc was installed previously, attempt to upgrade it:

	brew upgrade gcc

If gcc is already installed, you’ll get a message like:

`Warning: gcc 13.1.0 is already installed.`

If there is another version of `gcc` installed, say, `gcc-7.3.0`, installed while installing NCL, then the Homebrew version should be referenced as `gcc-13`. Typing `gcc-13 -v` or `gfortran-13 -v` will provide the version information for the Homebrew version. 
	
## Install Eclipse IDE for Scientific Computing ##

The Eclipse IDE that supports Fortran is known as the Eclipse IDE for Scientific Computing.  (It used to be known variously as Parallel Tools Platform with Photran, or Eclipse for Parallel Application Developers.  Note also: The recent "Photon" version of the IDE (4.8.0, June 2018), is not the same as "Photran" the older name for the Fortran project).

You may need to first install a Java Developer kit, if one does not already exist, although the current version of the installer, `2023-03`, indicates that it includes a Java RTE. If it appears necessary to install one, see:
	
- [https://www.oracle.com/java/technologies/javase-downloads.html](https://www.oracle.com/java/technologies/javase-downloads.html)

### Eclipse Installer ###

The Eclipse Installer provides a convenient way of installing the Eclipse Development Environment and the Eclipse IDE for Scientific Computing (both are required).  The installer is described at:  

- [https://www.eclipse.org/downloads/packages/installer](https://www.eclipse.org/downloads/packages/installer)

Download the Eclipse Installer and click on the downloaded image file `eclipse-inst-jre-mac64.dmg` and run the `Eclipse Installer.app` that appears.  

The installer provides a scrolling list of packages.  Scroll down and select `Eclipse for Scientific Computing` and click on `Install`.  Accept the licenses and certificates.  Installation takes a little while, and there may be messages warning about installation taking longer than usual.  Accept the certificates, and launch Eclipse when installation is done.

The Fortran Development User Guide for the current release of Eclipse (2023-03, as of 1 May 2023) is at: [https://help.eclipse.org/2023-03/](https://help.eclipse.org/2023-03/)

### Set up ###

When Eclipse is run for the first time, there will be some set up to do.  

Select a directory as a workspace.  It proposed `/Users/bartlein/eclipse-workspace`, which seems fine, and check the button to use that as the default.

A welcome screen will appear, with various shortcuts and tutorials.  They are probably of more use after playing with Eclipse for a while that right away.  You can proceed right to the "workbench" (i.e. the GUI) by clicking on the orange button in the upper right.

### Updating Eclipse ###

Once Eclipse is set up, it can be updated using its `Help` menu.

## New Project Example ##

An illustrative example is to create a project `test_netcdf` that reads a file of long-term means of 20th Century Reanalysis data.  Here's a typical file structure, in this example, in my `/Users/bartlein/Projects/` folder.

	/20CRA
		/data
			/ltms
		/f90
			/main_programs
			/modules
		/project_templates
			/netcdf_openmp_project
		/workspace
			/test_netcdf
			/test_netcdf_openmp 

The resulting intermediate and executable files for this example will appear in `/workspace/test_netcdf`.  
The folder `/project_templates/netcdf_openmp_project` contains a project with the various settings already set, which can be used to create a new project by importing it into Eclipse and adding source files.  (This will be explained later--see below.)

### Creating a new Fortran project ###

Start Eclipse, and in the `Select directory as workspace...` dialog, browse to the `/20CRA/workspace/` folder.  This folder may ultimately contain multiple projects.

There are two ways to create a new project:

1. Click on `File` > `New` > `Project`, click on `Fortran`, and click on `Fortran Project`, or
2. Right-click in the Project Explorer window, click on `New` > `Fortran Project`

In the `Project name` field, type `test_netcdf`, uncheck `Use default location` tab, and browse to the folder `../20CRA/workspace/test_netcdf` and click on `Open`.  

Then in the `Project type` window, click on `Executable (Gnu Fortran on MacOS X`), and click on the `Next` button.

The first time through, a dialog box will open, stating `Open the Fortran perspective?`  Click on the `Remember my decision` check box, and then click on `Open Perspective`.  This adds some Fortran-specific buttons to the toolbar and some windows.

The `Project Explorer` window should now contain a `test_netcdf` entry.  You can expose the `Project Explorer` window by clicking on `Window > Show View > Project Explorer`.

### Set the properties ###

Either right-click on `test_netcdf` in the `Project Explorer` window, and click `Properties`, or use the Eclipse menu `Project > Properties`.  A properties page will open.

#### Fortran Build Environment ####

Click on `Fortran Build` and then `Environment`.  On the `Configuration` field, select `[All configurations]`  This is important--if `Debug` or `Release` is selected, the changes will apply only to that configuration, and not both.

Add the current path.  The path can be obtained by typing in a Terminal window:

	echo $PATH

which will return something like (be sure to type the dollar sign):

`/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin`
	
Click on `Add…` and in the `Name` field, enter `PATH`, and in the `Value` field, add the current path.  Click on `Apply` (not the highlighted `Apply and Close`!)

#### Fortran Build Settings ####

Click on Settings under Fortran Build. On the first panel, again for `[All configurations]`, add the following to the Command field: `-fopenmp -ffree-line-length-160 -Wno-tabs`, so that the field looks like:

	gfortran -fopenmp -ffree-line-length-160 -Wno-tabs 
	
The switch `-fopenmp` enables OpenMP, `-ffree-line-length-160` increases the line length, and `-Wno-tabs` suppresses the tab warnings.

Then click on the `Directories` “folder” under `GNU Fortran Compiler`. Make sure [All configurations] is selected. Use the green add button to add the following include directory paths:

	/usr/local/Cellar/netcdf-fortran/4.6.0/include
	/usr/local/Cellar/netcdf-fortran/4.6.0/lib

(Note that, whenever netCDF is updated, the specific folder name where netCDF resides (`/4.9.2`) will have to be changed to match the current version.

Next, on the `Optimization` folder, select `Optimize most (-O3)` if OpenMP is being used.

Next on `Fortran Build`, `Settings`, click on `MacOS X Fortran Linker` and on the Libraries folder.

- In the upper Libraries (-l) pane, add `netcdff` and `gomp`
- In the lower Library search path (-L) pane, add `/usr/local/Cellar/netcdf/4.9.0/lib`
- 
(Note the two `f`'s in `netcdff`.)

On macOS Big Sur and later, the path to the `lSystem` library is sometimes not set correctly, so you may need to add the following to the library search path: `/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib`. Keep checking to see that the settings are being applied to `[All Configurations]`.

Click on `Apply and Close`. The `Includes` entry under `test_netcdf` in the Project Explorer window should now be populated with paths to a number of different folders.

### Add code ###

There are several ways to add source code (`*.f90` files) to a project.  If the code does not exist, and will be composed here, click on the `New Fortran Source File` button on the toolbar, or with `test_netcdf` selected in the `Project Explorer` right-click, and click on `New` and `Fortran Source File`.  However, the better way to add new code, is to create a file in, for example, the `../f90/main_programs/` folder, and then drag into the Projects pane in Eclipse, dropping it onto the project name.  This will create a link to that file, as opposed to creating the file in the `/workspace` folder.  This is particularly helpful in reducing the proliferation of modules.

Here we're going to add the existing files `test_01.f90` the main program and `netCDF_subs.f90` a module of subroutines.  The easiest way to do that is to browse to each files in a file manager (`Finder`), copy the file, switch to Eclipse, select `test_netcdf` in the `Project Explorer` window, right-click and paste.

Or, you can simply drag the files into the `Project Explorer` window, dropping them on `test_netcdf`. 

Eclipse will ask whether you want to move the file or create a link.  Creating a link is usually the best choice because moving the file will indeed move it, and deleting it from the project will delete it completely.

### Build the Project ###

There are several ways to build the project:

1. using the "hammer" tool on the toolbar
2. right-clicking on `test_netcdf` in the `Project Explorer` window, and clicking on `Build Project`
3. from the `Project` menu, click on `Build Project`

Build the `Debug` version first.

(Note that `gfortran` is fussy about tab characters and unused variables, and may produce a lot of warnings the first time a file is compiled.)

### Run the Project ###

If the project is successfully built, it can be run by clicking on the binary file (e.g. `/test_netcdf/Debug/test_netcdf`) in a file browser, which will pop up a Terminal window.

#### Run configurations ####

The project can also be run "inside" of Eclipse by creating a `Run Configuration`.  From the Eclipse `Run` menu, click on `Run Configurations`.  First, click on the "Filter" button (the rightmost one on the button bar), and maker sure `Filter Closed Projects` is selected (and nothing else).

Then  

1. Add a new `C/C++ Application` (even though this is Fortran), and 
1. in the `Name:` field (if not already autofilled), enter e.g. `test_netcdf Debug`, 
1. in the `Project` field enter `test_netcdf` (or browse to it), and 
1. in the `C/C++ Application:` field, enter e.g., `Debug/test_netcdf`, or click on `Search Project...` 

If there is a command line argument (e.g. a path and filename of a particular data file or info file, it can be entered in the `Environment` tab of the `Run Configurations...` tab.

Click on `Apply`, and then `Run`.  The project should run in a `Console` window in the Eclipse IDE.  The `Run` button on the toolbar can also be used to run the project.

## Using OpenMP ##

OpenMP capabilities can be added to a program as follows:

1. In the `Properties` for a particular project, click on `Fortran Build` and `Settings`, and under `GNU Fortran Complier` add the text `-fopenmp` after `gfortran` in the `Command` field (with a space, e.g. `gfortran -fopenmp`)
2. Then click on `MacOS X Fortran Linker` and `Libraries`, and add the text `gomp` to the upper (`Libraries`) pane, and click on `Apply and Close`
3. In the main program, add `use omp_lib` and add appropriate OpenMP directives.

## New Project with Existing Settings ##

It can be tedious to set all of the paths, include and library files, etc.  A workaround is to create a simple project, which contains no source files, but for which which all of the the necessary settings have been set.  An example of such a project is contained in the folder `/new_project_templates/netcdf_openmp_project`.  The idea is to copy this folder (renaming the folder while doing so), then open the project in Eclipse, rename it, and add source files.

To do this, copy the folder `/netcdf_openmp_project` to, say, `/workspace/netcdf_openmp_project`, and rename that folder to, e.g. `test_netcdf_openmp` (which will be the name of the new project.

Then in Eclipse, use the menu (`File` `Open Projects from File System…`) to open the project. Browse to newly renamed folder `test_netcdf_openmp`, and open it (but not either the `Debug` or `Release` folders). Click `Finish`. 

The project will appear under the name `netcdf_openmp_project`.  Rename it to `test_netcdf_openmp` by right-clicking on `netcdf_openmp_project` in the `Project Explorer` window, and clicking `Rename`.

Then add source files to the project in the usual way.  

Alternatively, it's possible to simply copy and paste and existing project in the workspace to make a copy.  After copying, delete existing source-code files that are no longer applicable, clean the project using the `Project > Clean...` dialog, and then add new source-code files.


## Other stuff ##

- [https://gcc.gnu.org/onlinedocs/gcc-11.3.0/gfortran.pdf](https://gcc.gnu.org/onlinedocs/gcc-11.2.0/gfortran.pdf)
- [https://gcc.gnu.org/onlinedocs/gcc-11.3.0/libgomp.pdf](https://gcc.gnu.org/onlinedocs/gcc-11.2.0/libgomp.pdf)

gfortran stack vs. heap:  [https://jblevins.org/log/segfault](https://jblevins.org/log/segfault)

Installing or switching between different versions of a formula:  [https://stackoverflow.com/questions/3987683 /homebrew-install-specific-version-of-formula](https://stackoverflow.com/questions/3987683/homebrew-install-specific-version-of-formula)](https://wiki.eclipse.org/images/c/cd/Eclipse-ptp-XSEDE15-complete.pdf)

## Troubleshooting multiple gcc/gfortran installations ##

There is an issue that can arise if NCL is installed on the same system, and following the NCL instructions, an older version of `gcc` was installed.  The solution, unfortuately, is to uninstall and reinstall Homebrew, `gcc` and `netcdf`.

Uninstall Homebrew (**Note:  This uninstalls Homebrew, and all of its installed packages**):

	 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"

Reinstall Homebrew

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Install `gcc`:

	brew install gcc

There will probably be permission issues that turn up, concerning access to `/usr/local'

Take ownership of `/usr/local`:

	cd /usr/local
	sudo chown -R $(whoami):staff *
	
You may have to do this:

	brew link --overwrite gcc

Check to see if the (newer) `gfortran` is the default:

	which gfortran
	gfortran -v
	
Reinstall the other packages, including `netcdf` as above.

/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib






