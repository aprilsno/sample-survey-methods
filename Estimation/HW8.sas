libname data "/home/u49497589/BIOS664/Estimation";

*** Analyze according to the Taylor Series Linearization (TSL) method;

proc surveyfreq data = data.ncvs_subset;
	weight pswt; 
	strata strata;
	cluster psu;
	tables sex*violent_crime*victim_off_rel / row cl;
run;

proc surveyfreq data = data.ncvs_subset;
	where violent_crime = 1;
	weight pswt; 
	strata strata;
	cluster psu;
	tables sex*victim_off_rel / row cl;
run;



proc surveymeans data = data.ncvs_subset plots=none sum clsum;
	where violent_crime = 1;
	domain time_day;
	weight pswt; 
	strata strata;
	cluster psu;
	var value_stolen; 
run;


