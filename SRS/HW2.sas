/******************************/
* Program: HW2_saraob.sas
* Programmer: Sara O'Brien
* Date Created: 01/31/2017
/*****************************/;

* Create PDF output file;
ODS PDF FILE="/home/u49497589/BIOS664/HW2_saraob.pdf" STYLE=JOURNAL;

* Import srs30 dataset;
proc import 
	out = srs30
    datafile = "/home/u49497589/BIOS664/srs30.csv" 
    dbms = csv replace; 
    getnames = yes; 
    datarow = 2; 
run;

* Add sample weight var to srs30;
data srs30;
	set srs30;
	samplingweight = 100/30;
run;

* Find std of sample;
proc means data = srs30 std;
	var y;
	title 'Std of srs30';
run;

* Find estimated population total (and its 95% CI);
proc surveymeans data = srs30 N=100 sum clsum plots=none;
	title 'Estimated population total';
	weight samplingweight; 
run;

* Import crime dataset;
proc import 
	out = crimes
    datafile = "/home/u49497589/BIOS664/crimes.csv" 
    dbms = csv replace; 
    getnames = yes; 
    datarow = 2; 
run;

* 2A. Add a sampling weight var to crimes dataset;
data crimes;
	set crimes;
	samplingweight = 7048107/5000;
run;

* 2B. Estimate percentage of crimes in which an arrest was made;
proc surveyfreq data=crimes N=7048107;
	title 'Estimated percentage of crimes with arrest';
	tables arrest/cl nofreq nowt;
	weight samplingweight;
run; 

* 2C. Estimate total number of burglaries;
proc surveymeans data=crimes N=7048107 sum clsum;
	title 'Estimated total burglaries';
	class crimetype;
	weight samplingweight;
	var crimetype;
run;

* Could alternatively obtain estimated percentages and multiply by N;
proc surveyfreq data=crimes N=7048107; 
	title 'Estimated % of crimes that were burglaries';
	tables crimetype/cl nofreq nowt;
	weight samplingweight;
run; 

* 2D. Estimate percentage of domestic-related crimes;
proc surveyfreq data=crimes N=7048107;
	title 'Estimated percentage of crimes that were domestic-related';
	tables domestic/cl nofreq nowt;
	weight samplingweight;
run; 

* Use proc surveymeans to get estimated mean and SE for CV;
* Note: these values are the same as those obtained in proc surveyfreq,
but not in percentage form;
proc surveymeans data=crimes N=7048107 mean clm;
	title 'Estimated mean and SE of domestic-related crimes';
	class domestic;
	weight samplingweight;
	var domestic;
run;

* Close pdf file;
ODS PDF CLOSE;
