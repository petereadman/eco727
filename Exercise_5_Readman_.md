## Exercise 5: Reproducing Angrist and Krueger’s Table 6

Peter Readman

---

### Plan    

---

- Use the Birth Quarter Data, prepared from Angrist and Krueger's paper
- Estimate log-Wage Regressions by OLS and 2SLS
- Reproduce Angrist and Krueger’s Table 6 estimates
- Comparing the Estimates
- Create a Table of Estimates from the log-Wage OLS and 2SLS regressions
- Reproduce Angrist and Krueger’s Table 6

---

### Preliminaries

---

### Part A: Use the “Birth Quarter.dta” Data

Table VI from Angrist and Krueger presents data from the 1940's cohort, so we'll restrict our data accordingly:


{{1}}


Let's peak at the data. We want to make sure we have 1980 census data and the number of observations matches those reported by A&K.


{{2}}


Confirmed. 

A&K's table VI includes 'Age' and 'Age-squared' which are measured in quarters of years. The Birth Quarter data we're using includes `ageq` (age in quarters of years) and we'll generate the required Age-squared variable from this. We're also going to need a 1st-quarter variable `q1`.


{{3}}


Done. Now we have everything we need to start reproducing the results for the tables.

---

### Part B: Estimate the log-Wage Regression by OLS and 2SLS


{{4}}


---

### Part C: Reproduce Angrist and Krueger’s Table 6

eststo column_1: regress lwklywge educ i.yob // OLS (1)

{{5}}


---

### Part D: Compare the Estimates

#### Wald estimate in Part B compared to the Wald estimates in Angrist and Krueger’s table 3

The estimates for the 1940s cohort differ from Angrist and Krueger’s results. The Wald estimate in Part B, using three birth-quarter instruments, is close to zero, while Angrist and Krueger report estimates between 0.0715 and 0.1020 in Table III. This suggests that the instruments are weaker within the 1940s cohort and capture less variation in schooling.

#### 2SLS estimate with three birth-quarter instruments compared to the 2SLS estimates with birth-quarter × birth-year instruments?

The 2SLS estimates tell a similar story. Using three birth-quarter instruments gives smaller and less precise estimates than models with birth-quarter × year-of-birth interactions. Adding interactions brings the estimates closer to those in Angrist and Krueger, likely because the interactions capture more variation in education.

#### Over-identification 

Over-identification tests show problems with both specifications. The Sargan test rejects the null for models with three birth-quarter instruments and for those with 29 birth-quarter × year-of-birth interactions. This suggests that the instruments may not satisfy the exclusion restriction, even with additional interactions.

---

### Part E: Create a Table of Estimates from Part B

Let's see all the regression results stored so far.


{{6}}



{{7}}


From the above, we can export to a LaTeX file for a more professional presentation.


{{8}}


---

### Part F: Reproduce Angrist and Krueger’s Table 6


{{9}}


Again, we can add some code and export this to LaTeX


{{10}}


---
