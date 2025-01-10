***** Exercise_1_Readman.do
***** accessing the cps outgoing rotation group files, 1982-2022
***** cps-org data extracted from ipums on 1/2/2024

cd "~/Dropbox/@10,000 feet and Runway/MA in Economics at Hunter/ECO 727 - Data Analysis and Research Methods/Analysis"
log using Exercise_1_Readman.smcl, name(results) replace
global ex=1
global lname="Readman"

* part d
* using the data
  use "../Data/cps_00003.dta", clear
  run data_check

* checking rotation groups for groups 4 and 8 only
  tab1 mish eligorg labforce, missing
  tabulate year mish, missing
  keep if mish == 4 | mish == 8
  
* confirming structure of data
  tabulate month mish  

* describing, summarizing the data
  describe
  summarize  
  
* listing last 10 observations
  list year serial month hwtfinl cpsid asecflag mish region pernum wtfinl in -10/l, noobs
  list cpsidv cpsidp earnweek2 hourwage2 age sex race empstat labforce occ1950 in -10/l, noobs
  list ind1950 classwkr uhrswork1 educ earnwt qearnwee hourwage paidhour union earnweek uhrsworkorg in -10/l, noobs  

* tabulating categorical variables with fewer than 50 categories
  foreach var of varlist ///
    month asecflag mish region sex race empstat labforce occ1950 ind1950 classwkr ///
    educ qearnwee paidhour union eligorg {
    qui tab `var'
    local cats = r(r)
    if `cats' > 50 {
        di "`var': `cats' categories"
    }
  }
  
  tab1 asecflag labforce eligorg month mish region sex race empstat classwkr educ qearnwee paidhour union, missing
  
* dropping any categorical variables that don't vary
  drop asecflag labforce eligorg

* checking race variable for recoding issues
  tabulate year race if year <= 2002, missing
  numlabel RACE, add
  tabulate year race  if inlist(race, 300, 650, 651, 652)
  
*** end part d

* part e
* compressing and saving data
  compress
  save "../Data/CPS ORGs, 1982-2024.dta", replace
  describe
  summarize 
*** end part e

log close results










