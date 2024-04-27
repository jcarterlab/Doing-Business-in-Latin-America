-- creates a series of measures to analyze % cuts in the cost of doing business in Latin America from 2015-2019
 with cuts as (
	 select st.country as country, 
		(st.yr2015 - st.yr2019) + (pr.yr2015 - pr.yr2019) + (co.yr2015 - co.yr2019) as total_cuts,
		(st.yr2015 - st.yr2019) as start_up_cuts,
		(pr.yr2015 - pr.yr2019) as property_cuts,
		(co.yr2015 - co.yr2019) as contract_cuts,
		(st.yr2019 + pr.yr2019 + co.yr2019) as still_to_cut,
		rank() over (order by (st.yr2019 + pr.yr2019 + co.yr2019) asc) as overall_rank,
		rank() over (order by st.yr2019 asc) as st_rank,
		rank() over (order by pr.yr2019 + co.yr2019 asc) as pr_rank,
		rank() over (order by co.yr2019 asc) as co_rank
	from startup as st
	join property as pr on st.country = pr.country
	join contracts as co on pr.country = co.country
 ),
 -- creates a final measure indicating the highest remaining relative cost (based on rank) in 2019
relative_rank as (
 	select country,
 		st_rank,
 		pr_rank,
 		co_rank,
 		case 
			when st_rank >= pr_rank and st_rank >= co_rank then 'Startup'
			when pr_rank >= st_rank and pr_rank >= co_rank then 'Property'
			else 'Contract'
		end as largest_relative_cost
 	from cuts
 )
 
-- selects the desired measures and orders by total cuts in descending order between 2015-2019
select c.country,
	c.total_cuts,
	c.start_up_cuts,
	c.property_cuts,
	c.contract_cuts,
	c.still_to_cut,
	c.overall_rank,
	r.largest_relative_cost
from cuts as c
join relative_rank as r on c.country = r.country
order by total_cuts desc;

