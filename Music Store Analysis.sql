use music_database;
select * from album;

-- Q1 : who is  the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;

-- Q2 : which countries have the most invoices?

select count(*) as c, billing_country from invoice
group by billing_country
order by c desc;

-- Q3 : what are top 3 values of total invoice?

select total from invoice
order by total desc
limit 3;

-- Q4 : which city has the best customers? we would like to throw a promotional music festival in the city we made the most money. write a query that
-- returns one city that has the higest sum of invoice totals. return the both city name sum of all invoice totals

select sum(total) as invoice_total,billing_city 
from invoice
group by billing_city
order by invoice_total desc;

-- Q5 : who is the best customer? the customer who has spent the most money will be declared the best customer. 
-- write a query that returns the person who has spent the most money?

select customer.customer_id,customer.first_name,customer.last_name, sum(invoice.total)as total
 from customer
 join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;


/* Question Set 2 - Moderate */


/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct email as Email,first_name,last_name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
order by email;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id,artist.name, count(artist.artist_id) as number_of_song
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id =album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_song desc
limit 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select  name, milliseconds from track
where milliseconds > (select avg(milliseconds) as avg_track_length from track)
order by milliseconds desc;


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */


select concat(first_name, ' ', last_name) customer, artist.name artist,
sum(i.unit_price*i.quantity) amount_spent
from customer
join invoice using(customer_id)
join invoice_line i using (invoice_id)
join track using (track_id)
join album using (album_id)
join artist using (artist_id)
group by customer,artist 
order by customer,amount_spent desc;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 desc
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;