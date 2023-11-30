/****************************
Assignment: BIOS664 HW5
Programmer: Sara O'Brien
Date: 2/28/23
*****************************/

* Pull in data;
libname pps '/home/u49497589/BIOS664/Cluster';

* Count per cluster;
proc sql;
	create table labor as
	select *, count(distinct person) as clustersize
	from pps.labor1
	group by cluster;
quit;

* Create a cluster-level file;
proc sort data=labor out=clusters(keep=cluster clustersize) nodupkey; by cluster; run;
proc freq data=clusters; tables clustersize; run;
proc means data=clusters sum; var clustersize; run;

* Stage 1: Select a PPS Sample of n=40 clusters (WITH REPLACEMENT);
proc surveyselect data=clusters method=pps_wr n=40 out = PPS_stg1 seed = 5000 stats;
    size clustersize; 
	samplingunit cluster;
run;

* Merge on cluster-level data for selected clusters;
data PPS_merge;
 merge PPS_stg1(in=in_smp)
       pps.labor1(in=in_frame);
 by cluster;
 if in_smp;
 if not in_frame then put '***WAR' 'NING: merge problem' cluster=;
run;

* 'NumberHits' = number of times each cluster was selected in sample, get the full list of observations to 
include in our sample.; 
data PPS_smp;
   set PPS_merge;
   do i = 1 to NumberHits;
      output;
   end;
run;

* Create 'cluster2' variable so that a different cluster identifier is used each time a cluster is sampled;
data PPS_smp2;
   set PPS_smp;
   cluster2=strip(cluster)||"_"||strip(i);
   keep cluster2 person clustersize SamplingWeight age WklyWage HoursPerWk;
run;

proc sort data=PPS_smp2; by cluster2; run;

* Stage 2: Select 2 persons per cluster;
proc surveyselect data=PPS_smp2(rename=(samplingweight=samplingweight1)) 
    method=srs n=2 
    out = PPS_stg2 seed = 5000 stats;
	strata cluster2;
run;

data PPS_smp_stg2;
	set PPS_stg2;
	WT=samplingweight1*Samplingweight;
run;

* Question: is our sample epsem?;
proc freq data=PPS_smp_stg2; tables WT; run;

* Do our weights sum back to the population total (478)?;
proc means data=PPS_smp_stg2 sum; var WT; run; 

* Estimate the mean age and wklywg based on the 2-stage sample;
proc surveymeans data=PPS_smp_stg2 mean clm plots=none; 
   cluster cluster2;
   var age wklywage;
   weight WT;
run;

* Create a binary variable that equals 1 if the participant usually works less than 40
hours per week and 0 otherwise (based on the HoursPerWk variable);
data PPS_binary;
	set PPS_smp_stg2;
	if HoursPerWk < 40 then binary=1;
	else binary=0;
run;

* Estimate the percentage of the target population who usually work fewer than 40 hours per week
based on your two-stage cluster sample, and give a 95% CI for each level of the variable and estimated DEFF;
proc surveyfreq data=PPS_binary N=115; 
	tables binary / cl nofreq nowt deff; 
	cluster cluster2;
	weight WT;
run;