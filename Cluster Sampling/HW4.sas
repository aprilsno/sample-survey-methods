/******************************/
* Program: HW4_saraob.sas
* Programmer: Sara O'Brien
* Date Created: 02/21/2023
/*****************************/

* Pull in data of interest;

libname bios664 '/home/u49497589/BIOS664/Cluster';

/* Compute estimated sample proportion, standard error, and DEFF */ 
* Note:  For cluster samples, specify the number of clusters (hospitals), 
NOT the number of observation units in the 'N=' option. To include the finite 
population correction in the SRS variance, specify the DEFF(FPC=YES) option in 
the PROC SURVEYFREQ statement;

proc surveyfreq data=bios664.hospital N=243 deff(fpc=yes); 
	tables success / cl nofreq nowt deff; 
	cluster hospid;
	weight WT;
run;

