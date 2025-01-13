***** Exercise_5_Readman.do
***** 
***** 

cd "~/Dropbox/@10,000 feet and Runway/MA in Economics at Hunter/ECO 727 - Data Analysis and Research Methods/Analysis"
log using Exercise_5_Readman.smcl, name(results) replace
set scheme s2color
global ex=5
global lname="Readman"

*part a: using the “Birth Quarter.dta” data
use "../Data/Birth Quarter.dta" if cohort==4, clear
run data_check
describe
assert _N == 486926

*** end part a

log close results