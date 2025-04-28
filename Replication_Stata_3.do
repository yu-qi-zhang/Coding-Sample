* This file replicates the following paper
* Cascio, E. U. (2009). Maternal Labor Supply and the Introduction of Kindergartens into American Public Schools. The Journal of Human Resources, 44(1), 140–170. http://www.jstor.org/stable/20648890

* The replication includes three parts
* (1) Basic cleaning from ASCII-coded raw data file
* (2) Descriptive statistics and regression following the paper
* (3) Generating various tables matching the forms in the paper

clear

/*
pick all variables, the 1990 census is organized by household members records follow their household record; to make is more concise I kept only part of the infixing process.
*/
cd "  "
clear
forvalues v=1/2{
	clear
infix str rectype 1  hhid 2-7 sample 9  state 11-12 areatype 18-19 hhsize 33-34 relate 9-10  sex 11 race 12-14 age 15-16 marsta 17 prwt 18-21 subfunit 36 subfrel 37 schtype 50 grade 51-52 grade_fin 51-52 born_num 89-90 hrwork 93-94 class 121 employ 91  famtype 151-152  employdq 210 hrworkdq 211 using DS000`v'/09952-000`v'-Data.txt,clear
save pick1990/All1990_`v'.dta,replace
}

/*Table 2
*/
use working_data/usekidmom_reg.dta,clear

keep if kidage==5|kidage==6
gen enroll=0
replace enroll=1 if public==1
replace enroll=2 if private==1
la def enroll 0 "not" 1 "Public school" 2"Private school", modify
la val enroll enroll
tabout enroll year if single==1&num04==0 [weight=resipop] using output/table1.tex,replace style(tex) c(col) layout(row) h3(nil)  h1(nil) dropc(6)  npos(row) 
tabout enroll year if single==1&num04>0 [weight=resipop] using output/table1.tex,append style(tex) c(col) layout(row) h3(nil) h2(nil) h1(nil) dropc(6)  npos(row) 
tabout enroll year if single==0&num04==0 [weight=resipop] using output/table2.tex,replace style(tex) c(col) layout(row) h3(nil)  h1(nil) dropc(6)  npos(row) 
tabout enroll year if single==0&num04>0 [weight=resipop] using output/table2.tex,append style(tex) c(col) layout(row) h3(nil)  h2(nil) h1(nil) dropc(6)  npos(row) 

/*Table 3
note: highdg need to adjust for 1950(all move to right for one column; deleta the last column)
*/
use working_data/usemomkid_reg.dta,clear
gen work=(hrwork_mean>0)
gen five=(num5>0|num6>0)
la def work 0 "not" 1 "Worked lastweek", modify
la val work work
gen hrtitle="Hours last week"
gen kid712title="Children aged 7-12"
gen kid1317title="Children aged 13-17"
gen agetitle="Age"
la def highdg 0 "not" 1 "High school degree", modify
la val highdg highdg
la def white 0 "not" 1 "White", modify
la val white white

preserve
la def work 0 "not" 1 "Worked lastweek", modify
la val work work
keep if five==1&single==1&num04==0
tabout work year [weight=resipop] using output/table3_1.doc,replace style(doc) c(col) layout(row) h3(nil)  h1(nil) dropc(7) f(2)
tabout hrtitle year [weight=resipop] using output/table3_1.doc,append style(doc) c(mean hrwork_mean) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout hrtitle year [weight=resipop] using output/table3_1.doc,append style(doc) c(sd hrwork_mean ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder npos(row)
restore

preserve
keep if five==1&single==1&num04==0
tabout work year [weight=resipop] using output/table3_1.tex,replace style(tex) c(col) layout(row) h3(nil)  h1(nil) dropc(7) f(2)
tabout hrtitle year [weight=resipop] using output/table3_1.tex,append style(tex) c(mean hrwork_mean) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout hrtitle year [weight=resipop] using output/table3_1.tex,append style(tex) c(sd hrwork_mean ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout highdg year [weight=resipop] using output/table3_1.tex,append style(tex) c(col) layout(row) h3(nil) h2(nil)  h1(nil) dropc(7) f(2) nohlines noborder
tabout white year [weight=resipop] using output/table3_1.tex,append style(tex) c(col) layout(row) h3(nil) h2(nil)  h1(nil) dropc(7) f(2) nohlines noborder
tabout kid712title year [weight=resipop] using output/table3_1.tex,append style(tex) c(mean num712 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout kid712title year [weight=resipop] using output/table3_1.tex,append style(tex) c(sd num712 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout kid1317title year [weight=resipop] using output/table3_1.tex,append style(tex) c(mean num1317 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout kid1317title year [weight=resipop] using output/table3_1.tex,append style(tex) c(sd num1317 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout agetitle year [weight=resipop] using output/table3_1.tex,append style(tex) c(mean age ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout agetitle year [weight=resipop] using output/table3_1.tex,append style(tex) c(sd age ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2)  npos(row) nohlines noborder
restore

preserve
keep if five==1&single==0&num04==0
tabout work year [weight=resipop] using output/table3_2.tex,replace style(tex) c(col) layout(row) h3(nil)  h1(nil) dropc(7) f(2)
tabout hrtitle year [weight=resipop] using output/table3_2.tex,append style(tex) c(mean hrwork_mean) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout hrtitle year [weight=resipop] using output/table3_2.tex,append style(tex) c(sd hrwork_mean ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout highdg year [weight=resipop] using output/table3_2.tex,append style(tex) c(col) layout(row) h3(nil) h2(nil)  h1(nil) dropc(7) f(2) nohlines noborder
tabout white year [weight=resipop] using output/table3_2.tex,append style(tex) c(col) layout(row) h3(nil) h2(nil)  h1(nil) dropc(7) f(2) nohlines noborder
tabout kid712title year [weight=resipop] using output/table3_2.tex,append style(tex) c(mean num712 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout kid712title year [weight=resipop] using output/table3_2.tex,append style(tex) c(sd num712 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout kid1317title year [weight=resipop] using output/table3_2.tex,append style(tex) c(mean num1317 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout kid1317title year [weight=resipop] using output/table3_2.tex,append style(tex) c(sd num1317 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout agetitle year [weight=resipop] using output/table3_2.tex,append style(tex) c(mean age ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout agetitle year [weight=resipop] using output/table3_2.tex,append style(tex) c(sd age ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2)  npos(row) nohlines noborder
restore

preserve
keep if five==1&single==1&num04==1
tabout work year [weight=resipop] using output/table3_3.tex,replace style(tex) c(col) layout(row) h3(nil)  h1(nil) dropc(7) f(2)
tabout hrtitle year [weight=resipop] using output/table3_3.tex,append style(tex) c(mean hrwork_mean) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout hrtitle year [weight=resipop] using output/table3_3.tex,append style(tex) c(sd hrwork_mean ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout highdg year [weight=resipop] using output/table3_3.tex,append style(tex) c(col) layout(row) h3(nil) h2(nil)  h1(nil) dropc(7) f(2) nohlines noborder
tabout white year [weight=resipop] using output/table3_3.tex,append style(tex) c(col) layout(row) h3(nil) h2(nil)  h1(nil) dropc(7) f(2) nohlines noborder
tabout kid712title year [weight=resipop] using output/table3_3.tex,append style(tex) c(mean num712 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout kid712title year [weight=resipop] using output/table3_3.tex,append style(tex) c(sd num712 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout kid1317title year [weight=resipop] using output/table3_3.tex,append style(tex) c(mean num1317 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout kid1317title year [weight=resipop] using output/table3_3.tex,append style(tex) c(sd num1317 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout agetitle year [weight=resipop] using output/table3_3.tex,append style(tex) c(mean age ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout agetitle year [weight=resipop] using output/table3_3.tex,append style(tex) c(sd age ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2)  npos(row) nohlines noborder
restore

preserve
keep if five==1&single==0&num04==1
tabout work year [weight=resipop] using output/table3_4.tex,replace style(tex) c(col) layout(row) h3(nil)  h1(nil) dropc(7) f(2)
tabout hrtitle year [weight=resipop] using output/table3_4.tex,append style(tex) c(mean hrwork_mean) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout hrtitle year [weight=resipop] using output/table3_4.tex,append style(tex) c(sd hrwork_mean ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout highdg year [weight=resipop] using output/table3_4.tex,append style(tex) c(col) layout(row) h3(nil) h2(nil)  h1(nil) dropc(7) f(2) nohlines noborder
tabout white year [weight=resipop] using output/table3_4.tex,append style(tex) c(col) layout(row) h3(nil) h2(nil)  h1(nil) dropc(7) f(2) nohlines noborder
tabout kid712title year [weight=resipop] using output/table3_4.tex,append style(tex) c(mean num712 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout kid712title year [weight=resipop] using output/table3_4.tex,append style(tex) c(sd num712 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout kid1317title year [weight=resipop] using output/table3_4.tex,append style(tex) c(mean num1317 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout kid1317title year [weight=resipop] using output/table3_4.tex,append style(tex) c(sd num1317 ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout agetitle year [weight=resipop] using output/table3_4.tex,append style(tex) c(mean age ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2) nohlines noborder
tabout agetitle year [weight=resipop] using output/table3_4.tex,append style(tex) c(sd age ) sum layout(row) h3(nil) h2(nil) h1(nil) dropc(7) f(2)  npos(row) nohlines noborder
restore

/* Table 4
policyvar: Kratio
other controls:  white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317
fixed effect: state year
dependent : work hr_mean
type: single type num04 num02 num78 num34
*/
cd "/Users/fileyu7/Desktop/kindergarten"
use working_data/usemomkid_reg,clear
log using "tryweight.smcl", replace

log close
translate tryweight.smcl tryweight.pdf, replace fontsize(9)

// DID: Single,no younger children
qui areg work Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year if five==1&num04==0&single==1 [weight=wt], absorb(state) vce(cl state)
mat var=e(V)
sca vK_areg=var[1,1]
dis _b["Kratio"] " , " sqrt(vK_areg)
/*qui reghdfe work Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317  if five==1&num04==0&single==1 [weight=resipop], absorb(state year) vce(cl state)
mat var=e(V)
sca vK_reghdfe=var[1,1]
dis _b["Kratio"] " , " sqrt(vK_reghdfe)
*/
qui areg hrwork_mean Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year if five==1&num04==0&single==1 [weight=wt], absorb(state) vce(cl state)
mat var=e(V)
sca vK=var[1,1]
dis _b["Kratio"] " , " sqrt(vK)
dis e(N)
log off
qui areg work Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year if five==1&num04==0&single==0 [weight=wt], absorb(state) vce(cl state)
mat var=e(V)
sca vK=var[1,1]
log on
// DID: Single,no younger children
dis _b["Kratio"] " , " sqrt(vK)
log off
qui areg hrwork_mean Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year if five==1&num04==0&single==0 [weight=wt] ,absorb(state) vce(cl state)
mat var=e(V)
sca vK=var[1,1]
log on
dis _b["Kratio"] " , " sqrt(vK)
dis e(N)

reg work Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year c.hr_trend##c.hr_trend if five==1&num04==0&single==1 [weight=resipop], absorb(state) vce(cl state)
areg hrwork_mean Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year c.wk_trend##c.wk_trend if five==1&num04==0&single==1 [weight=resipop], absorb(state) vce(cl state)
areg work Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year c.hr_trend##c.hr_trend if five==1&num04==0&single==0 [weight=resipop], absorb(state) vce(cl state)
areg hrwork_mean Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year c.wk_trend##c.wk_trend if five==1&num04==0&single==0 [weight=resipop], absorb(state) vce(cl state)


cd "/Users/fileyu7/Desktop/kindergarten"
use working_data/usekidmom_reg,clear
bysort state year:egen pub_trend=mean(public)
bysort state year:egen pri_trend=mean(private)
keep if kidage==5|kidage==6
qui areg public Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year if num04==0&single==1 [weight=resipop], absorb(state) vce(cl state)
mat var=e(V)
sca vK=var[1,1]
dis _b["Kratio"] " , " sqrt(vK)
qui areg private Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year if num04==0&single==1 [weight=resipop], absorb(state) vce(cl state)
mat var=e(V)
sca vK=var[1,1]
dis _b["Kratio"] " , " sqrt(vK) " , " e(N)
qui areg public Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year if num04==0&single==0 [weight=resipop], absorb(state) vce(cl state)
mat var=e(V)
sca vK=var[1,1]
dis _b["Kratio"] " , " sqrt(vK)
qui areg private Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year if num04==0&single==0 [weight=resipop], absorb(state) vce(cl state)
mat var=e(V)
sca vK=var[1,1]
dis _b["Kratio"] " , " sqrt(vK) " , " e(N)


areg public Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year pub_trend if num04==0&single==1 [weight=resipop], absorb(state) vce(cl state)
areg private Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year pri_trend if num04==0&single==1 [weight=resipop], absorb(state) vce(cl state)
areg public Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year pub_trend if num04==0&single==0 [weight=resipop], absorb(state) vce(cl state)
areg private Kratio white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year pri_trend if num04==0&single==0 [weight=resipop], absorb(state) vce(cl state)

**(4)
cd "/Users/fileyu7/Desktop/kindergarten"
// DDD: Single,no younger children
use working_data/usemomkid_reg,clear
# delimit ;
qui reg work c.Kratio##five white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year i.state
      white#five c.age##c.age#five c.num04##c.num04#five c.num712##c.num712#five c.num5##c.num5#five c.num6##c.num6#five c.num1317##c.num1317#five i.year#five i.state#five if num34>0&single==1 [weight=wt], absorb(state) vce(cl state)
;
#delimit cr
log off
mat var=e(V)
mat coef=e(b)
sca bKf=coef[1,5]
sca vKf=var[5,5]
log on
dis bKf " , " sqrt(vKf) 

log off
# delimit ;
qui reg hrwork_mean c.Kratio##five white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year i.state
      white#five c.age##c.age#five c.num04##c.num04#five c.num712##c.num712#five c.num5##c.num5#five c.num6##c.num6#five c.num1317##c.num1317#five i.year#five i.state#five if num34>0&single==1 [weight=wt], absorb(state) vce(cl state)
;
#delimit cr
mat var=e(V)
mat coef=e(b)
sca bKf=coef[1,5]
sca vKf=var[5,5]
log on
// Hours worked
dis bKf " , " sqrt(vKf) " , " e(N)


# delimit ;
qui reg work c.Kratio##five white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year i.state
      white#five c.age##c.age#five c.num04##c.num04#five c.num712##c.num712#five c.num5##c.num5#five c.num6##c.num6#five c.num1317##c.num1317#five i.year#five i.state#five if  num34>0&single==0 [weight=resipop], absorb(state) vce(cl state)
;
#delimit cr

mat var=e(V)
mat coef=e(b)
sca bKf=coef[1,5]
sca vKf=var[5,5]
dis bKf " , " sqrt(vKf) 

# delimit ;
qui reg hrwork_mean c.Kratio##five white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year i.state
      white#five c.age##c.age#five c.num04##c.num04#five c.num712##c.num712#five c.num5##c.num5#five c.num6##c.num6#five c.num1317##c.num1317#five i.year#five i.state#five if  num34>0&single==0 [weight=resipop], absorb(state) vce(cl state)
;
#delimit cr
mat var=e(V)
mat coef=e(b)
sca bKf=coef[1,5]
sca vKf=var[5,5]
dis bKf " , " sqrt(vKf) " , " e(N)


**(5)
# delimit ;
qui reghdfe  work c.Kratio##five  white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 
      white#five c.age##c.age#five c.num04##c.num04#five c.num712##c.num712#five c.num5##c.num5#five c.num6##c.num6#five c.num1317##c.num1317#five i.year#five i.state#five if num04==0&num78>0&single==1 [weight=wt], absorb(state year) vce(cl state)
;
#delimit cr

mat var=e(V)
mat coef=e(b)
sca bKf=coef[1,5]
sca vKf=var[5,5]
dis bKf " , " sqrt(vKf) 

# delimit ;
qui reghdfe hrwork_mean c.Kratio##five white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 
      white#five c.age##c.age#five c.num04##c.num04#five c.num712##c.num712#five c.num5##c.num5#five c.num6##c.num6#five c.num1317##c.num1317#five i.year#five i.state#five if num04==0&num78>0&single==1 [weight=wt], absorb(state year) vce(cl state)
;
#delimit cr
mat var=e(V)
mat coef=e(b)
sca bKf=coef[1,5]
sca vKf=var[5,5]
dis bKf " , " sqrt(vKf) " , " e(N)


# delimit ;
qui reg work c.Kratio##five white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year i.state
      white#five c.age##c.age#five c.num04##c.num04#five c.num712##c.num712#five c.num5##c.num5#five c.num6##c.num6#five c.num1317##c.num1317#five i.year#five i.state#five if num78>0&single==0 [weight=resipop], absorb(state) vce(cl state)
;
#delimit cr

mat var=e(V)
mat coef=e(b)
sca bKf=coef[1,5]
sca vKf=var[5,5]
dis bKf " , " sqrt(vKf) 


# delimit ;
qui reg hrwork_mean c.Kratio##five white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year i.state
      white#five c.age##c.age#five c.num04##c.num04#five c.num712##c.num712#five c.num5##c.num5#five c.num6##c.num6#five c.num1317##c.num1317#five i.year#five i.state#five if num78>0&single==0 [weight=resipop], absorb(state) vce(cl state)
;
#delimit cr
mat var=e(V)
mat coef=e(b)
sca bKf=coef[1,5]
sca vKf=var[5,5]
dis bKf " , " sqrt(vKf) " , " e(N)



**(5)kids
cd "/Users/fileyu7/Desktop/kindergarten"
use working_data/usekidmom_reg,clear
gen five=(kidage==5|kidage==6)

# delimit ;
qui reg public c.Kratio##five white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year i.state
      white#five c.age##c.age#five c.num04##c.num04#five c.num712##c.num712#five c.num5##c.num5#five c.num6##c.num6#five c.num1317##c.num1317#five i.year#five i.state#five if num04==0&num78>0&single==1 [weight=resipop], absorb(state) vce(cl state)
;
#delimit cr

mat var=e(V)
mat coef=e(b)
sca bKf=coef[1,5]
sca vKf=var[5,5]
dis bKf " , " sqrt(vKf) 

# delimit ;
qui reg private c.Kratio##five white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year i.state
      white#five c.age##c.age#five c.num04##c.num04#five c.num712##c.num712#five c.num5##c.num5#five c.num6##c.num6#five c.num1317##c.num1317#five i.year#five i.state#five if num04==0&num78>0&single==1 [weight=resipop], absorb(state) vce(cl state)
;
#delimit cr
mat var=e(V)
mat coef=e(b)
sca bKf=coef[1,5]
sca vKf=var[5,5]
dis bKf " , " sqrt(vKf) " , " e(N)


# delimit ;
qui reg public c.Kratio##five white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year i.state
      white#five c.age##c.age#five c.num04##c.num04#five c.num712##c.num712#five c.num5##c.num5#five c.num6##c.num6#five c.num1317##c.num1317#five i.year#five i.state#five if num04==0&num78>0&single==0 [weight=resipop], absorb(state) vce(cl state)
;
#delimit cr

mat var=e(V)
mat coef=e(b)
sca bKf=coef[1,5]
sca vKf=var[5,5]
dis bKf " , " sqrt(vKf) 


# delimit ;
qui reg private c.Kratio##five white c.age##c.age c.num04##c.num04 c.num712##c.num712 c.num5##c.num5 c.num6##c.num6 c.num1317##c.num1317 i.year i.state
      white#five c.age##c.age#five c.num04##c.num04#five c.num712##c.num712#five c.num5##c.num5#five c.num6##c.num6#five c.num1317##c.num1317#five i.year#five i.state#five if num04==0&num78>0&single==0 [weight=resipop], absorb(state) vce(cl state)
;
#delimit cr
mat var=e(V)
mat coef=e(b)
sca bKf=coef[1,5]
sca vKf=var[5,5]
dis bKf " , " sqrt(vKf) " , " e(N)






