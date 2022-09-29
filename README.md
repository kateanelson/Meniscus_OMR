# Meniscus_OMR
An OMR system for the meniscus study



# OMR form design

### period\_diary\_maker\_2.R  

This R script acts as a master controller. It takes a list of ID numbers and creates a PDF copy of the Meniscus period diary with

* QR Code showing ID number - for assignment of  booklets to participants
* Human readable ID number
* Questions to check off
* OMR encoded date and ID boxes

Running this script will call

### OMR_functions.R

This script includes some customised functions that help to encode questions as OMR boxes to print to the survey sheets. 
It also has some neat functions for turning the OMR output data in to tidy data frames.

### Outputs

The scripts will generate PDF files which can be printed. You'll find examples in the *output* folder.

--

# OMR

Code based on [https://github.com/chrissyhroberts/OMR_LSHTM](https://github.com/chrissyhroberts/OMR_LSHTM) and this [https://github.com/Udayraj123/OMRChecker](https://github.com/Udayraj123/OMRChecker)

* Complete the survey forms by inking in the boxes. 
* Don't ink inside the ID and date areas. This will break things
* Take a photo of the form (or scan it, but use `--noCropping` option
* Put the photos (JPG or PNG) in to the `OMR/inputs/draft_period` folder.
* Do not remove the `template.json` or `omr_marker.png` files
* Open a command line and cd to the `OMR` folder
* Run the OMR software with `python3 main.py` 
	* See documentation in the user guide on the project wiki [https://github.com/Udayraj123/OMRChecker/wiki/](https://github.com/Udayraj123/OMRChecker/wiki/)

### Outputs 
* The OMR software will generate files in the `OMR/outputs/draft_period` folder
* Get the CSV file from `OMR/outputs/draft_period/Results`

 --

# Analysis

### analyser.R  
This R script will pull the data from the results file.

Basic functions are

* Read the date data, convert from OMR format to a date, then impute 6 additional dates to complete the week
* Read the ID data, convert from OMR format to a string
* Read various Questions from the results file, converting them in to tidy data and binding to a dataset as it goes
* Create output data object `data.out`
