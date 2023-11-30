/*****************************************
Assignment: BIOS664 HW6
Programmer: Sara O'Brien
Date: 3/23/2023
*****************************************/

* Assign libref;
libname sys "/home/u49497589/BIOS664/Systematic";

* Select systematic sample of size n=51;
proc surveyselect 
	data=sys.medreimb
	method=sys
	n=51
	out=sys_med
	seed=2000 
	stats;
run;

* Estimate mean annual expenditures per patient and its standard error;
proc surveymeans data=sys_med N = 500 mean clm plots=none; 
   var medicalexp;
   weight SamplingWeight;
run;

* Standard proc means to check samp size calc assumptions;
proc means data=sys_med;
	var medicalexp;
run;

