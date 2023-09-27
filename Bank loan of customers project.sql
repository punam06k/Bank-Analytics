create database finance;
use finance;


select count(*) from finance_1_csv;
select * from finance_1_csv;
update finance_1_csv set issue_d = str_to_date(issue_d, '%d-%m-%Y');


select * from finance2;
update finance2 set earliest_cr_line = str_to_date(earliest_cr_line, '%d-%m-%Y');
update finance2 set last_pymnt_d = str_to_date(last_pymnt_d, '%d-%m-%Y');
update finance2 set last_credit_pull_d = str_to_date(last_credit_pull_d, '%d-%m-%Y');

alter table finance_1_csv add primary key (id);
alter table finance2 add constraint foreign key (id) references finance_1_csv (id);

-- KPI 1: Year wise loan amount stats
select year(issue_d) as 'Year', 
round(avg(loan_amnt),2) as 'Average Loan Amount'
from finance_1_csv
group by year(issue_d)
order by avg(loan_amnt);

-- KPI 2: Grade & Subgrade wise Revol_bal
select f1.grade, f1.sub_grade, 
sum(f2.revol_bal) as 'Total Revol Bal'
from finance_1_csv as f1
left join  finance2 as f2
on f1.id = f2.id
group by f1.grade, f1.sub_grade
order by 1,2;

-- KPI 3: Total Payment for Verified Status vs Total Payment for Non Verified Status
select f1.verification_status, 
round(avg(f2.total_pymnt),2) from finance_1_csv as f1
left join finance2 as f2
on f1.id = f2.id
where verification_status in ('Not Verified', 'Verified')
group by f1.verification_status;


-- KPI 4: State wise & last_credit_pull_d wise loan_status
select year(f2.last_credit_pull_d) as 'Year',
f1.loan_status as 'Loan Status',
count(f1.addr_state) 'Count of States' 
from finance_1_csv as f1
left join finance2 as f2
on f1.id = f2.id
where year(f2.last_credit_pull_d) is not null
group by year(f2.last_credit_pull_d), f1.loan_status
order by 1,2;

-- KPI 5: Home ownership vs last payment date stats
select year(f2.last_credit_pull_d), f1.home_ownership, 
round(avg(f2.last_pymnt_amnt),2)
from finance_1_csv as f1
left join finance2 as f2
on f1.id = f2.id
group by year(f2.last_credit_pull_d)
order by 1; 
