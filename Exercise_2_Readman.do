***** Exercise_2_Readman.do
***** preparing the CPS ORG Data, 1982-2024
***** cps-org data extracted from ipums and prepared on 1/4/2024

cd "~/Dropbox/@10,000 feet and Runway/MA in Economics at Hunter/ECO 727 - Data Analysis and Research Methods/Analysis"
log using Exercise_2_Readman.smcl, name(results) replace
global ex=2
global lname="Readman"
global eyear=2024
global tcscale=1.5

* part a
* using prepared CPS ORGs data 1982-2024
  use "../Data/CPS ORGs, 1982-2024.dta", clear
  run data_check

* describing, summarizing, and listing the data 
  describe
  summarize
  list year serial month hwtfinl cpsid mish region pernum wtfinl cpsidv in -10/l, noobs
  list cpsidp earnweek2 hourwage2 age sex race empstat occ1950 ind1950 classwkr in -10/l, noobs
  list uhrswork1 educ earnwt qearnwee hourwage paidhour union earnweek uhrsworkorg in -10/l, noobs

* drop any variables not needed
  drop serial cpsid cpsidp pernum hwtfinl wtfinl
*** end part a 

* part b

* recoding missing values with .
  replace region=. if region ==97
  replace earnweek2=. if earnweek2==999999.99
  replace hourwage2=. if hourwage2==999.99
  replace sex=. if sex==9
  replace race=. if race==999
  replace empstat=. if empstat==00
  replace occ1950=. if inlist(occ1950, 997, 999)
  replace ind1950=. if inlist(ind1950, 000, 001, 998, 999)
  replace classwkr=. if inlist(classwkr, 00, 99)
  replace uhrswork1=. if uhrswork1==999
  replace educ=. if inlist(educ, 000, 001, 999)
  replace hourwage=. if hourwage==999.99
  replace paidhour=. if inlist(paidhour, 0, 6, 7)
  replace union=. if union ==0
  replace earnweek=. if earnweek==9999.99
  replace uhrsworkorg=. if inlist(uhrsworkorg, 998, 999)

* replacing sex with dummy variable for female
  generate female = sex-1
  drop sex
  order female, before(race)
  
* recoding paidhour as a dummy variable
  replace paidhour = paidhour-1

* recoding race
  replace race=650 if inlist(race, 651, 652) & year>=2003
  replace race=700 if inrange(race, 800, 830) & year>=2003
  tab year race, missing

* recoding grade
  generate grade =.
  **1982-1991
  replace grade=0  if educ==2 & year<=1991 // (none or preschool)
  replace grade=1  if educ==11 & year<=1991
  replace grade=2  if educ==12 & year<=1991
  replace grade=3  if educ==13 & year<=1991
  replace grade=4  if educ==14 & year<=1991
  replace grade=5  if educ==21 & year<=1991
  replace grade=6  if educ==22 & year<=1991
  replace grade=7  if educ==31 & year<=1991
  replace grade=8  if educ==32 & year<=1991
  replace grade=9  if educ==40 & year<=1991
  replace grade=10 if educ==50 & year<=1991
  replace grade=11 if educ==60 & year<=1991
  replace grade=12 if (educ==72 | educ==73) & year<=1991 // 72 is `diploma unclear'
  replace grade=13 if educ==80 & year<=1991
  replace grade=14 if educ==90 & year<=1991
  replace grade=15 if educ==100 & year<=1991
  replace grade=16 if educ==110 & year<=1991
  replace grade=17 if educ==121 & year<=1991
  replace grade=18 if educ==122 & year<=1991
  **1992-2024 (Jaeger 1997)
  replace grade=0   if educ==2  & year>=1992
  replace grade=2.5 if educ==10 & year>=1992 // grades 1-4
  replace grade=5.5 if educ==20 & year>=1992 // grades 5-6
  replace grade=7.5 if educ==30 & year>=1992 // grades 7-8
  replace grade=9   if educ==40 & year>=1992 // grade 9
  replace grade=10  if educ==50 & year>=1992 // grade 10
  replace grade=11  if educ==60 & year>=1992 // grade 11
  replace grade=12  if (educ==71 | educ==73) & year>=1992 // 71 is `no diploma'
  replace grade=13  if educ==81 & year>=1992 // some college, no degree
  replace grade=14  if (educ==91 | educ==92) & year>=1992 // academic or vocational associate's degree
  replace grade=16  if educ==111 & year>=1992
  replace grade=18  if inlist(educ, 123, 124, 125) & year>=1992
  order grade, before(educ)

* recoding occupation
  recode occ1950 ///
    (0/99=1) /// professional, technical
    (100/290=2) /// managers, officials, proprietors
    (300/390=3) /// clerical, kindred
    (400/490=4) /// sales
    (500/594=5) /// craftsmen
    (600/690=6) /// operatives
    (700/720=7) /// service (private hh)
    (730/790=8) /// service (other)
    (810/970=9) /// laborers
    (595=10) /// armed forces
    , generate(occupation) 
  * check everything is recoded 
    tab occ1950 if occ1950~=. & occupation==.
  
* recoding industry
  recode ind1950 ///
    (105/239=1) /// agriculture, fisheries, metal mining, coal mining
    (246/246=2) /// construction
    (306/399=3) /// durable manufacturing
    (406/499=4) /// nondurable manufacturing
    (506/598=5) /// communications, transportation, utilities
    (606/627=6) /// wholesale trade
    (636/699=7) /// retail trade
    (716/756=8) /// professional services, fire
    (868/879=8) /// professional services, fire
    (897/899=8) /// professional services, fire
    (888/896=9)  /// education, welfare services
    (906/946=10) /// public administration
    (806/859=11) /// other services
    (997/998=11)  /// other services
    , generate(industry)
  * check everything is covered
  tab ind1950 if ind1950~=. & industry==.

* replacing missing values of earnweek and hourwage
  replace earnweek = earnweek2 if missing(earnweek) & !missing(earnweek2)
  replace hourwage = hourwage2 if missing(hourwage) & !missing(hourwage2)
  drop earnweek2 hourwage2

* creating topcode variable to identify top-coded values of earnweek 
  generate topcode=.
  replace topcode=1 if earnweek==999 & inrange(year, 1982, 1988)
  replace topcode=1 if earnweek>=1923 & inrange(year, 1989, 1997)
  replace topcode=1 if earnweek>=2884.61 & inrange(year, 1998, $eyear)

* replacing top-coded values of earnweek with 1.5 times the top-coded values
  replace earnweek=$tcscale*999 if inrange(year, 1982, 1988) & topcode==1
  replace earnweek=$tcscale*1923 if inrange(year, 1989, 1997) & topcode==1
  replace earnweek=$tcscale*2884.61 if inrange(year, 1998, $eyear) & topcode==1

* labeling new variables female, paidhour, grade, occupation, industry, topcode
  *labeling for female
  label define FEMALE 0 "male" 1 "female"
  label value female FEMALE
  *labeling for paidhour
  label define PAIDHOUR 0 "not paid hourly" 1 "paid hourly", modify
  label value paidhour PAIDHOUR
  *labeling for grade
  label variable grade "highest grade completed"
  *labeling for occupation
  label define OCCUPATION 1 "professional, technical" ///
                          2 "managers, officials, proprietors" ///
                          3 "clerical, kindred" ///
                          4 "sales" ///
                          5 "craftsmen" ///
                          6 "operatives" ///
                          7 "service (private hh)" ///
                          8 "service (other)" ///
                          9 "laborers" ///
                          10 "armed forces" 
  label value occupation OCCUPATION
  label variable occupation "occupation (1-10)"
  *labeling for industry
  label define INDUSTRY 1 "agriculture, fisheries, metal mining, coal mining" ///
                        2 "construction" ///
                        3 "durable manufacturing" ///
                        4 "nondurable manufacturing" ///
                        5 "communications, transportation, utilities" ///
                        6 "wholesale trade" ///
                        7 "retail trade" ///
                        8 "professional services, fire" ///
                        9 "education, welfare services" ///
                        10 "public administration" ///
                        11 "other services"
  label value industry INDUSTRY
  label variable industry "industry (1-11)"
  *labeling for topcode
  label variable topcode "topcode indicator"

* dropping variables replaced by grade, occupation, industry
  drop educ occ1950 ind1950

*** end part b

* part c
* saving the data
  compress
  save "../Data/CPS ORGs, 1982-$eyear, Cleaned.dta", replace
  describe
  summarize
*** end part c

log close results