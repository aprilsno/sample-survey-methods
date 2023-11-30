/******************************/
* Program: HW3_saraob.sas
* Programmer: Sara O'Brien
* Date Created: 02/08/2017
/*****************************/;

* Create PDF output file;
ODS PDF FILE="/home/u49497589/BIOS664/Stratification/HW3_sasoutput_saraob.pdf" STYLE=JOURNAL;

* Pull in data of interest;
libname bios664 '/home/u49497589/BIOS664/Stratification';

data height;
	set bios664.collegeht;
run;

/*** QUESTION 3C ***/

* Step 1: Sort sort data by stratification variable (yos);
proc sort data=height; 
	by yos; 
run;

* Step 2: Create data set 'strat_popsize' with stratum ('yos') population sizes and a dataset 
'strat_sampsize_prop' with stratum sample sizes;

proc freq data=height noprint;
	tables yos / list out=strat_popsize(keep=yos COUNT rename=(COUNT=_total_));
run;

data strat_samsize_prop;
	set strat_popsize;
	_nsize_ = round((500/1500)*_total_);  *f=n/N=500/1500;
run;

proc print data=strat_samsize_prop noobs; 
	var yos _total_ _nsize_; 
run;

* Step 3: Select PROPORTIONATE stratified sample (stratfied by 'yos') of size n=500 from 'height' data set 
using sample sizes in 'strat_samsize_prop'. Examine weights by stratum, final sample counts, and ensure 
weights sum back to population total (1500);
 
proc surveyselect data=height method=srs n=strat_samsize_prop out = strat_sam_prop seed = 22 stats; 
	strata yos;
run;

proc freq data=strat_sam_prop; 
	tables yos*SamplingWeight / list missing; 
run;

proc means data=strat_sam_prop sum; 
	class yos; 
	var SamplingWeight; 
run; * Weights sum to 1500;


* Step 4: Estimate sample means, standard errors, and compute 95% CIs for 'height' from 'strat_sam_prop' data 
set, specifying 'strat_popsize' as data set with stratum population sizes, examine overall and by yos;

proc surveymeans data=strat_sam_prop N=strat_popsize mean clm plots=none;
   stratum yos;
   domain yos;
   weight SamplingWeight;
   var height;
run;

/*** QUESTION 3D ***/

data height2;
	set bios664.collegeht;
run;

* Step 1: Sort sort data by stratification variable (gender);
proc sort data=height2; 
	by gender; 
run;

* Step 2: Create data set 'strat_popsize2' with stratum ('gender') population sizes 
and a dataset 'strat_sampsize_prop2' with stratum sample sizes;

proc freq data=height2 noprint;
	tables gender / list out=strat_popsize2(keep=gender COUNT rename=(COUNT=_total_));
run;

data strat_samsize_prop2;
	set strat_popsize2;
	_nsize_ = round((500/1500)*_total_);  *f=n/N=500/1500;
run;

proc print data=strat_samsize_prop2 noobs; 
	var gender _total_ _nsize_; 
run;

* Step 3: Select PROPORTIONATE stratified sample (stratfied by 'gender') of size n=500 from 
'height' data set using sample sizes in 'strat_samsize_prop2'. Examine weights by stratum,
 final sample counts, and ensure weights sum back to population total (1500);
 
proc surveyselect data=height2 method=srs n=strat_samsize_prop2 out = strat_sam_prop2 seed = 21 stats; 
	strata gender;
run;

proc freq data=strat_sam_prop2; 
	tables gender*SamplingWeight / list missing; 
run;

proc means data=strat_sam_prop2 sum; 
	class gender; 
	var SamplingWeight; 
run; * Weights sum to 1500;


* Step 4: Estimate sample means, standard errors, and compute 95% CIs for 'height' from 
'strat_sam_prop' data set, specifying 'strat_popsize' as data set with stratum population sizes,
examine overall and by yos;

proc surveymeans data=strat_sam_prop2 N=strat_popsize2 mean clm plots=none;
   stratum gender;
   domain gender;
   weight SamplingWeight;
   var height;
run;

ods pdf close;
