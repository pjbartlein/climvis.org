# Workflow for making an animation #

Example:  Make animations of skin temperature (T<sub>s</sub>) and of 2-m air temperature - skin temperature (T2m - T<sub>s</sub>)

Basic layout of files and folders:

1. A big data folder(s) for storing downloaded data and calculated values like long-term means and anomalies.  This folder will be too large to sync at GitHub.
2. A working folder with processed data files, NCL scripts, other scripts and so on, including a folder for completed maps.  This folder should be a GitHub repository (e.g. `climvis-figs`)
3. A working folder with the Markdown, R Markdown and various other files and folders that make up the web page (e.g. the Bootstrap `/site-libs` folder and the HAniS support files.  This should also be a GitHub repository (e.g. `climvis.org`) and is copied to `http://pages.uoregon.edu/clivis/` (`climvis.org`)

Overall steps:

1. download data (monthly time series).
2. calculate new variables (e.g. T2m - T<sub>s</sub>), if necessary.
3. calculate long-term means and anomalies (Anomaly calculation isn't really necessary, but it's efficient to do at this stage).
4. copy the resulting long-term means to `/climvis-figs/data/ERA5-Atm/ltm_monthly/`
5. edit and run an ncl script to make the maps
6. use the ImageMagick `mogrify` command-line tool to trim whitespace from the maps.  (NCL always writes to a square page.)
7. edit the three HAniS support files: `varname.html`, `varname_config.txt`, and `varname_files.txt'.
8. using FileZilla or by mounting the folder on the server, copy the `/png` folder and HAniS support files to 
`sftp.uoregon.edu/climvis/public_html/content/anim/ltm/globe/varname/...`  
(user: `climvis` password: `GCA_2023_Sedge`)
9. test by loading `https://climvis.org/global/varname/varname.html`
10. Editing the appropriate Markdown file (e.g. `animations.md`) and "knitting" it to `.html' in R Studio via an R Markdown file  (e.g.` annimations.Rmd`) (Or, when major changes are made, rebuilding the web site in R Studio.)
11. copy the updated/rebuilt website `.html` and support files to the server.

*Some debugging of the following will be necessary.*

## Data ##

### Download data ###

Before downloading data, you'll need to get an CDS account.  The first time through, the web page should prompt you to set one up.

Here's the URL for the ERA5 monthly-averaged data on single levels:  
[[https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels-monthly-means?tab=overview]](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels-monthly-means?tab=overview).

Click on the `Download Data` tab, and make the following selections:

- Product type:  `Monthly averaged reanalysis`
- Variable:  `Skin temperature`
- Year:  `Select all` (or just through 2020, to match the existing data).
- Month:  `Select all`
- Time:  `00:00` (the only possible selection for Monthly averaged reanalysis data)
- Geographical area: `Whole available region`
- Format:  `NetCDF`

Click on the green button.  When the data are ready, you'll see a Download data button.  The file will have a cryptic name, but you can discover the name of the variable, `skt` in this case, using Panoply or `ncdump`.  Rename the file to, for example, `ERA5_skt_monthly_197901-202012.nc`.  Move the file to the "big data" folder(s).

### Get long-term means and anomalies ###

Getting the long-term means, 1991-2020, for example, is easy to do with a combination of CDO and NCO command-line commands.  Open a terminal window in the folder with the downloaded data, and paste in the following:

	cdo selyear,1991/2020 ERA5_skt_monthly_197901-202012.nc ERA5_skt_monthly_199101-202012.nc
	cdo ymonmean ERA5_skt_monthly_199101-202012.nc ERA5_skt_monthly_199101-202012_ltm.nc
	cdo -b F64 sub ERA5_skt_monthly_197901-202012.nc ERA5_skt_monthly_199101-202012_ltm.nc ERA5_skt_monthly_197901-202012_anm1991-2020.nc 
	ncpdq -O ERA5_skt_monthly_197901-202012_anm1991-2020.nc ERA5_skt_monthly_197901-202012_anm1991-2020.nc 

The first line grabs a subset of years (1991-2020) from the downloaded file, the second line gets the long-term means for that subset, the third line gets the anomalies, and the fourth line repacks the anomalies (to "short" netCDF variables).  There are more scripts in the file `/climvis-figs/scripts/cdo-and-nco/cdo_ltm&anm_ERA5-Atm.txt` Move the long-term mean file `ERA5_skt_monthly_199101-202012_ltm.nc` to the `/climvis-figs/data/ERA5-Atm/ltm_monthly` folder.

### Calculate a new variable ###

Get a new variable, in this case the 2m air temperature minus the skin temperature.  This can be done in NCL, but is easy to do in CDO and NCO:

	cdo -b F64 sub ERA5_t2m_monthly_197901-202012.nc ERA5_skt_monthly_197901-202012.nc ERA5_t2m-skt_monthly_197901-202012.nc 
	ncpdq -O ERA5_t2m-skt_monthly_197901-202012.nc ERA5_t2m-skt_monthly_197901-202012.nc 
	ncrename -v t2m,t2m-skt ERA5_t2m-skt_monthly_197901-202012.nc
	ncatted -a long_name,t2m-skt,o,c,"2m Air Temp - Skin Temp" ERA5_t2m-skt_monthly_197901-202012.nc
	ncatted -a standard_name,t2m-skt,o,c,"T2m-TS" ERA5_t2m-skt_monthly_197901-202012.nc

The first line subtracts `skt` from `t2m`, the second line repacks the difference, the third line renames `t2m` which got propagated to the difference file to `t2m-skt`, and the fourth and fifth lines add new long and standard names for `t2m-skt`.  Next, get the long-term means and anomalies of `t2m-skt` as above.

## Maps ##

### Create folder(s) in `/content` ###

The animations consist of a folder of `.png` files, and three HAniS control files. Create the following folders and subfolders, e.g. for `skt`: `../climvis-figs/content/anim/ltm/globe/skt_globe_1991-2020_ltm/png`, and create a similar one for `t2m-skt`.

### Edit an NCL file ###

Most of the time, an existing NCL script can be edited to create the maps for a new variable.  For example, to plot `skt`, it's possible to simply edit the NCL script for `t2m`: `t2m_glrob.ncl` (Note: `glrob` stands for a map of the globe using the Robinson projection.  Because only the file and variable names will differ (the same color scale will be used), only line 3 and line 6 in the following would need to be changed. (Note that the line numbers are not part of the file.)

	01: ; 1-up plot of a scalar variable
	02:
	03: mapvar = "skt"
	04: data_path = "../../data/ERA5-Atm/ltm_monthly/"
	05: map_path = "../../maps/global/" + mapvar + "_globe_1991-2020_ltm/png/"
	06: title_0 = "Skin Temperature (~S~o~N~C~N~)"
	07: title_2 = "Data: ERA5 Reanalysis"
	08: title_3 = "1991-2020 Long-Term Mean"
	09: ...
	
Line 44 in this file could also be changed from the comment `; 2m air temperature` to `; skin temperature`

For plotting `t2m-skt`, the same color scale will be used, but different outpoints will need to be specified.  (See below for color-scale selection.). Two additional sections of code will need to be changed:

	33: plotvar = plotvar

(removing the `- 273.15` that converted the input `t2m` data from Kelvin to deg C), and

	44: ; 2m - skin temperature difference
	45: level0 = new((/ 15 /), float)
	46: level0 = (/-10, -5, -2, -1, -0.5, -0.2, -0.1, 0, 0.1, 0.2, 0.5, 1, 2, 5, 10 /)
	47: level0_begclr = 238
	48: level0_endclr = 253

Only line 44 and 46 were changed in this code chunk, to change the comment and to specify a pseudo-logarithmic scale.  There are 15 cutpoints, and 16 colors (numbers 238 through 253) specified here. (The old outpoints for `t2m`were `level0 = (/-35, -30, -25, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25, 30, 35 /)`)

### Run the NCL file ###

If you're using SublimeText on a Mac, typing cmd-b will save and run the file.  Otherwise, save the file, open a command window in the `../climvis-figs/ncl/ncl_maps/` folder, and type for example, `ncl skt_glrob.ncl`.

### Trim the `.png` files ###

NCL plots things into a square "viewport", which would leave a lot of white space around the maps.  This can be trimmed (chopped) using the ImageMagick `mogrify` command (see `../climvis-figs/scripts/imagemagick/` for scripts for other map types.  Open a command window in a `/png` folder (e.g. `../climvis-figs/content/anim/ltm/globe/t2m-skt_globe_1991-2020_ltm/png`) and copy in the following:

	mogrify -gravity South -chop 0x260 *.png 
	mogrify -gravity North -chop 0x220 *.png

(This takes a few seconds, and the command prompt may come back before all of the file are done.)

### Edit the HAniS support files ###

There are three text files that HAniS uses to serve the `.pngs` as an animation, and `.html` file that is displayed in the browser, a configuration file, `*_config.txt`, and a list of files that make up the animation, `*_files.txt`.  Copy these from an existing variable's folder into, e.g. `../climvis-figs/content/anim/ltm/globe/skt_globe_1991-2020_ltm` and rename them appropriately, e.g. to `skt_globe_1991-2020_ltm.html`.

In the `.html` file, line 6, the title, and line 20, the reference to the configuration file should be changed to e.g. `<title>ERA5 Skin Temperature 1991-2020</title>` and `onload="HAniS.setup('skt_globe_1991-2020_ltm_config.txt','handiv')">`k respectively..

In the `*_config.txt` file, line 1, the reference to the file of filenames should be changed to e.g. `file_of_filenames = skt_globe_1991-2020_ltm_files.txt`.

In the file of filenames, the individual file names should be change to reference the files in the `/png` subfolder, e.g.

### Copy the files to the server ###

Copy the files to the server (i.e, to `pages.uoregon.edu/climvis/private_html/content/`).  If using FileZilla, the following Site Manager information should work:

	Protocol: SFTP - SSH File Transfer Protocol
	Host: sftp.uoreogn.edu
	Logon Type: Normal
	User: climvis
	Password: GCA_2023_Sedge

Browse to the folder `/home2/climvis/public_html/content/anim/ltm/globe` and copy the folder `../climvis-figs/content/anim/ltm/globe/skt_globe_1991-2020_ltm/` to the server.

### Test the animation ###

In a browser, enter the URL `https://pages.uoregon.edu/climvis/content/anim/ltm/globe/skt_globe_1991-2020_ltm/` and click on the `skt_globe_1991-2020_ltm.html` link.

## Web site ##

The next step in adding or updating animations or plots is to work on the website.  The website is built in R Studio using R Markdown, using a "Bootstrap theme" to implement the dropdown menus and overall design of the page.  See [[https://bookdown.org/yihui/rmarkdown/]](https://bookdown.org/yihui/rmarkdown/).  In addition to a few support files that don't change often, the individual pages on the website are built from a Markdown file (e.g. `animations.md`) that contains text and links to the the animation `.html` file (e.g. 'skt_globe_1991-2020_ltm.html`) and a related R Markdown file (e.g. `animations.Rmd`) that refers to the Markdown file, and is "knitted" in R Studio to create an `.html` file that can be copied to the website, and also to update the structure of the website.

### Markdown files ###

Markdown files are just text files with some very simple formatting tags embedded (e.g. \*a word or phrase\* gets rendered as *a word or phrase*, or \** subhead \** gets rendered as **subhead**). Links to `.html` files on a server are constructed like this: \[[climvis.org]](https://climvis.org), and when rendered appear as [[climvis.org]](https://climvis.org). The outer pair of square brackets delimits the link that appears on a page (and the inner pair appears as part of the link), while the parentheses delimit the URL.

"Rendering" is done by a Markdown conversion program, which reads the text file and converts it to an `.html` file (or `.pdf`, `.docx`, etc.). See [https://www.markdownguide.org/](https://www.markdownguide.org/).

So Markdown files can be constructed in a text editor, or in the editor in R Studio.  In practice, it's easiest to use a dual-pane dedicated Markdown editor that provides a live preview.  Examples are:
- [[MultiMarkdownComposer]](https://multimarkdown.com/), macOS, get from Mac .app store, probably the best one for the Mac;
- [[Macdown]](https://macdown.uranusjr.com/), macOS, free, but has an annoying tendency to "flicker" when one is typing; and
- [[MarkdownPad 2]](http://markdownpad.com/news/2013/introducing-markdownpad-2/), the best one for Windows.

All three editors have a built-in Markdown rendering program, and can use a custom `.css` file to format the html a particular way (e.g. fonts and font-sizes, width of page, etc.).  The `.css` file used here is `page_01.css` which is one of the support files that gets uploaded to the server.

### Adding a new animation or image (editing a Markdown file)###

The two new animations can be added to the Animations page by using a Markdown editor (or text editor), and adding two links. The temperature section of the `animations.md` would then look like this:

	**Temperature**  
	
	[[2m air temperature]](../content/anim/ltm/globe/t2m_globe_1991-2020_ltm/t2m_globe_1991-2020_ltm.html) 
	[[2m air temperature (polar)]](../content/anim/ltm/polar/t2m_polar_1991-2020_ltm/t2m_polar_1991-2020_ltm.html)
	[[Surface net radiation & 2m air temp]](../content/anim/ltm/globe/t2m_snr_globe_1991-2020_ltm/t2m_snr_globe_1991-2020_ltm.html)  
	[[Skin temperature]](../content/anim/ltm/globe/skt_globe_1991-2020_ltm/skt_globe_1991-2020_ltm.html)
	[[2m air temperature - Skin temperature]](../content/anim/ltm/globe/t2m-skt_globe_1991-2020_ltm/t2m-skt_globe_1991-2020_ltm.html)

Save the edited Markdown file as usual.

### Rendering the Markdown file and updating the website ###

The next step is to render the Markdown file in R Studio, turning it into an `.html` file that can be uploaded to the website.  Here are the steps:  
1. Open R Studio in the `climvis.org` folder--this can conveniently be done by double-clicking on the `clmvis.org.Rproj` project file.  
2. Open the associated R Markdown file, i.e. `animations.Rmd` for rendering the `animations.md` file just made above.  The R Markdown file contains some header information, plus a reference to the Markdown file `(```{r child="animations.md"}`).  
3. "knit" (render) the file by clicking on the `Knit` button in R Studio.  It might take a few seconds for the preview image of the rendered `.html` file to appear.  
4. As currently set up, this will create the file `animations.html` in the `/climvis.org/docs/` folder.  
5. Copy the `.html` file to `pages.uoregon.edu/climvis/private_html/`.  
6. Update the GitHub repository by committing and pushing the changed file.

