
libname weight "/home/u49497589/BIOS664/Weighting";

* Run proc freq to calculate response rate;
proc freq data=weight.smstudy_data;
	table type;
	where type ^= 'INELIGIBLE';
run;

* Delete ineligible cases from the sample;
* Create a 0/1 indicator variable for whether or not the case responded;
data tus_sample;
	set weight.smstudy_data;
	if TYPE="INELIGIBLE" then delete;
	RESPONDENT=(TYPE="RESPONDENT");
run;

* Calculate the percentage of cases that are respondents within each demographic group;
proc freq data=tus_sample;
	table sex*respondent / nocol nopercent;
	table agegrp*respondent / nocol nopercent;
run;

* Create a dataset of respondents;
data tus_respondents;
	set tus_sample;
	where respondent = 1;
run;

* Calculate smoking prevalence by gender, age category, and education level;
proc freq data=tus_respondents;
	table sex*currsmk / nocol nopercent;
	table agegrp*currsmk / nocol nopercent;
	table edu_level*currsmk / nocol nopercent;
run;

* Calculate the design-consistent estimate of the current smoking prevalence as a
percentage, only among respondents, and report it along with its standard error in
the table under part;
proc surveyfreq data=tus_respondents;
	strata strata;
	table currsmk;
	weight basewt;
run;

* Calculate total weights in each weighting class;
proc freq data=tus_sample noprint; 
	weight basewt; 
	tables sex*agegrp / out=weights_all(drop=percent rename=(count=total_wt)); 
run;

* Calculate the weight of respondents in each weighting class;
proc freq data=tus_sample noprint; 
	where respondent=1;
	weight basewt; 
	tables sex*agegrp / out=weights_resp(drop=percent rename=(count=resp_wt)); 
run;

* Calculate psi;
data tus_adj;
	merge weights_all weights_resp;
	by sex agegrp;
	psi=resp_wt/total_wt;
	NR_adjust=1/psi;
run; 

proc print data=tus_adj noobs; run;

* Merge onto dataset and calculate final NR weights for respondents;
proc sort data=tus_sample; by sex agegrp; run;

data tus_adj_final;
	merge tus_sample
       	  tus_adj(keep=sex agegrp psi);
	by sex agegrp;
	if respondent=0 then delete; *remove non-respondents;
	NRWT=basewt*1/psi;
run;

* Check that weight sums before and after the adjustment match;
proc means data=tus_sample sum; var basewt; run;
proc means data=tus_adj_final sum; var NRWT; run;

* Calculate the design-consistent estimate of the current smoking prevalence as a
percentage based on the non-response adjusted weight;
proc surveyfreq data=tus_adj_final;
	strata strata;
	weight nrwt;
	table currsmk;
run;

* Calculate total NR weight in each weighting class;
proc freq data=tus_adj_final noprint; 
	weight NRWT; 
	tables edu_level / out=tus_cov_wt(drop=percent rename=(count=total_wt)); 
run;

* Calculate weight adjustment (omega);
data tus_cov_adj;
	set tus_cov_wt;
	if edu_level=1 then poptot=10572;
	else if edu_level=2 then poptot=20570;
	else if edu_level=3 then poptot=45388 ;
	omega=poptot/total_wt;
run; 

proc print data=tus_cov_adj noobs; run;

*Merge onto dataset and calculate final PS weights for respondents;
proc sort data=tus_adj_final; by edu_level; run;

data tus_cov_final;
	merge tus_adj_final
       	  tus_cov_adj(keep=edu_level omega);
	by edu_level;
	ANALYSIS_WT=NRWT*omega;
run;

*Check that weights sums to the control totals;
proc means data=tus_cov_final sum; class edu_level; var ANALYSIS_WT; run;

* Calculate the design-consistent estimate of the current smoking prevalence as a
percentage based on the final, coverage adjusted weights;
proc surveyfreq data=tus_cov_final;
	strata strata;
	weight analysis_wt;
	table currsmk;
run;
