--Ở Project này chúng ta sử dụng dataset đã được xử lý ở PROJECT 1.

/*1) Doanh thu theo từng ProductLine, Year  và DealSize?
Output: PRODUCTLINE, YEAR_ID, DEALSIZE, REVENUE*/
select productline,YEAR_ID, DEALSIZE, sum(sales) as REVENUE from sales_dataset_rfm_prj
group by productline,YEAR_ID, DEALSIZE

  /*2) Đâu là tháng có bán tốt nhất mỗi năm?
Output: MONTH_ID, REVENUE, ORDER_NUMBER*/
select year_id,month_ID,ORDER_NUMBER from
(select year_id, month_ID, sum(sales) as REVENUE,count(ordernumber) as ORDER_NUMBER, 
 rank() over(partition by year_id order by sum(sales),count(ordernumber))
from sales_dataset_rfm_prj
group by year_id,month_ID) as a
where rank =1

/* 3) Product line nào được bán nhiều ở tháng 11?
Output: MONTH_ID, REVENUE, ORDER_NUMBER*/
select productline,month_ID, DEALSIZE, sum(sales) as REVENUE,count(ordernumber) as ORDER_NUMBER 
from sales_dataset_rfm_prj
where month_ID = 11
group by productline,month_ID, DEALSIZE
order by sum(sales) desc , count(ordernumber) desc limit 1

/*4) Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? 
Xếp hạng các các doanh thu đó theo từng năm.
Output: YEAR_ID, PRODUCTLINE,REVENUE, RANK*/
select * from 
(select YEAR_ID, PRODUCTLINE,sum(sales) as REVENUE, RANK() over(partition by YEAR_ID order by sum(sales ) desc) from sales_dataset_rfm_prj
where country ='UK'
group by YEAR_ID, PRODUCTLINE) as a
where rank = 1

/*5) Ai là khách hàng tốt nhất, phân tích dựa vào RFM 
(sử dụng lại bảng customer_segment ở buổi học 23*)/

with customer_analyst as 
(select contactfullname,postalcode,
current_date - max(orderdate) as R,
count(distinct ordernumber) as F,
sum(sales) as M 
from sales_dataset_rfm_prj
group by contactfullname,postalcode),

analyst1 as 
(select contactfullname,postalcode,
ntile(5) over(order by R desc) asR_score,
ntile(5) over(order by F ) as F_score,
ntile(5) over(order by M ) as M_score
from customer_analyst),

analyst2 as 
(select contactfullname,postalcode,
 cast(R_score as varchar)|| cast(R_score as varchar)||cast(R_score as varchar) as rfm_score from analyst1)
 
select contactfullname,postalcode, rfm_score from analyst2 as a join segment_score as b 
 on a.rfm_score = b.scores
 where segment = 'Champions'
