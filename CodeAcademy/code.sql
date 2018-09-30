{\rtf1\ansi\ansicpg1252\cocoartf1561\cocoasubrtf600
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;\red251\green2\blue7;\red0\green0\blue0;\red0\green0\blue0;
\red251\green2\blue7;}
{\*\expandedcolortbl;;\cssrgb\c100000\c14913\c0;\cssrgb\c0\c0\c0;\csgray\c0\c0;
\cssrgb\c100000\c14913\c0;}
\margl1440\margr1440\vieww10680\viewh15800\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0  \
 --FUNNELS WITH WARBY PARKER\
 \
 --1. Understand the Warby Parker quizUnderstand the quiz\
 \
 SELECT * \
 FROM survey\
 LIMIT 10;\
 \
 --'survey' table contains 'question', 'user_id', and 'response'\
 \
--2. Understand at which points users \'93give up\'94 the quiz\
\
 SELECT question, COUNT(DISTINCT user_id) AS 'responses'\
 FROM survey\
 GROUP BY question;\
 \
 --Question 1. What are you looking for? 500\
 --Question 2. What's your fit? 475\
 --Question 3. Which shapes do you like? 380\
 --Question 4. Which colors do you like? 361\
 --Question 5. When was your last eye exam? 270\
 \
 SELECT COUNT(DISTINCT user_id) FROM survey;\
 \
 --There are 500 respondents\
 \
 --Question	Responses	Percent Completion\
	--1	500	100%\
	--2	475	95%\
	--3	380	80%\
	--4	361	95%\
	--5	270	75%\
\
--When was your last eye exam? was the least-answered question\'97-likely because readers don't remember or haven't had an eye exam\
--Which shapes do you like? was the second least-answered question-- maybe readers have more trouble deciding the answer to this one\
\
\
--HOME TRY-ON FUNNEL\
\
--4. Understand Warby Parker\'92s home try-on tracking \
\
 SELECT * \
 FROM quiz\
 LIMIT 5;\
 \
--Columns are: user_id, style, fit, shape, color\
\
 SELECT * \
 FROM home_try_on\
 LIMIT 5;\
 \
 --Columns are: 'user_id', 'number_of_pairs', 'address'\
\
 SELECT * \
 FROM purchase\
 LIMIT 5;\
 \
 --Columns are: 'user_id', 'product_id', 'style', 'model_name', 'color', 'price'\
 \
 --5. Create a new table with columns 'user_id', 'is_home_try_on', 'number_of_pairs', 'is_purchase'
\i \cf2 \
\

\i0 \cf3 \cb4 WITH funnel AS\
(SELECT \
 DISTINCT quiz.user_id,\
	home_try_on.user_id IS NOT NULL AS 'is_home_try_on',\
	home_try_on.number_of_pairs,\
purchase.user_id IS NOT NULL AS 'is_purchase'\
FROM quiz\
LEFT JOIN home_try_on \
  ON quiz.user_id = home_try_on.user_id\
 LEFT JOIN purchase\
  ON purchase.user_id = quiz.user_id)\
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0
\cf3 SELECT * FROM funnel\
LIMIT 10;
\i \cf5 \cb1 \

\i0 \cf0 \
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0
\cf0 --6. Analyze the funnel!\
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0
\cf0 \
WITH funnel AS\
(SELECT \
 DISTINCT quiz.user_id,\
	home_try_on.user_id IS NOT NULL AS 'is_home_try_on',\
	home_try_on.number_of_pairs,\
purchase.user_id IS NOT NULL AS 'is_purchase'\
FROM quiz\
LEFT JOIN home_try_on \
  ON quiz.user_id = home_try_on.user_id\
 LEFT JOIN purchase\
  ON purchase.user_id = quiz.user_id)\
SELECT COUNT(*) as 'browses', SUM(is_home_try_on) as 'home_try_on_conversions', \
SUM(is_purchase) as 'purchase_conversions', \
1.0 * SUM(is_home_try_on) / COUNT(*) as 'browse_conversion_rate', \
1.0 * SUM(is_purchase) / SUM(is_home_try_on) as 'home_try_on_conversion_rate'\
FROM funnel;\
\
--1000 browses, 750 home try on conversions (rate of 75%), 495 purchase conversions (rate of 66%)\
\
WITH funnel AS\
(SELECT \
 DISTINCT quiz.user_id,\
	home_try_on.user_id IS NOT NULL AS 'is_home_try_on',\
	home_try_on.number_of_pairs,\
purchase.user_id IS NOT NULL AS 'is_purchase'\
FROM quiz\
LEFT JOIN home_try_on \
  ON quiz.user_id = home_try_on.user_id\
 LEFT JOIN purchase\
  ON purchase.user_id = quiz.user_id)\
SELECT number_of_pairs, COUNT(user_id) AS 'users_per_num_pairs', SUM(is_purchase) AS 'num_pairs_conversions', 1.0 * SUM(is_purchase) / COUNT(user_id) AS 'num_pairs_conversion_rate'\
FROM funnel\
WHERE number_of_pairs IS NOT NULL\
GROUP BY number_of_pairs;\
\
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0
\cf0 --379 were sent 3 pairs, and 201 (53%) converted\
--371 were sent 5 pairs, and 294 (79%) converted\
--5 pairs for at-home try-on have a MUCH higher conversion rate!\
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0
\cf0 \
SELECT MAX(price), min(price)\
FROM purchase;\
\
--Prices range from $50 - $150\
\
SELECT model_name, COUNT(*), AVG(price)\
FROM purchase\
GROUP BY model_name\
ORDER BY 2 DESC;\
\
--Eugene Narrow, the most-bought model with 116 purchases, is $95, while Dawes, a close second with 107 purchases, is $150 -- the maximum price point\
\
--THE END!\
\
\
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\i \cf5 WITH funnel AS\
(SELECT \
 DISTINCT quiz.user_id,\
	CASE \
		WHEN home_try_on.user_id IS NOT NULL THEN 'True'\
		WHEN home_try_on.user_id IS NULL THEN 'False'\
	END as 'is_home_try_on',\
	home_try_on.number_of_pairs,\
	CASE \
		WHEN purchase.user_id IS NOT NULL THEN 'True'\
		WHEN purchase.user_id IS NULL THEN 'False'\
	END as 'is_purchase'\
FROM quiz\
LEFT JOIN home_try_on \
  ON quiz.user_id = home_try_on.user_id\
 LEFT JOIN purchase\
  ON purchase.user_id = quiz.user_id)\
SELECT * FROM funnel\
LIMIT 10;}