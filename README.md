# README

## What is this

This is my solution to Dataplor's take home interview coding challenge.

## How to run it

If you have docker installed, run `docker-compose up`. That should build and
install everything needed and run the local server.

Next, in a separate shell, run `docker-compose run --rm web bash` to enter the
container. From there run `rails db:prepare`

I've included a rake task to load the `nodes.csv` file into the database, as
well as a small sample `test_nodes.csv` (described in the problem statement)
and `test_birds.csv` (that I made up). These were sufficient to run manual
testing against the problem statement.

There is no large scale `birds.csv` file, however.

## The solution

Given the constraints/hints in the problem statement, I opted to represent the
tree in a relational database and handle traversing it with recursive queries
and appropriate indices. The api is being served up by Rails.  It's using
Sqlite for ease of setup/convenience, but that can trivially be swapped out for
postgres or other relational db of choice. I believe sqlite should be able to
handle the constraint of millions or even billions of records given
https://www.sqlite.org/limits.html. If this were a production app, I would
definitely reach for postgres first.

The recursive queries work by repeatedly joining the `trees` table to itself in
order to traverse up to ancestors or down through descendants. I considered a
few alternative approaches but this is the most balanced, allowing for easy
insertion of nodes.

Another option i considered was going with a document database like mongo and
storing paths to each node. For example:
```
| node_id | path            |
|---------+-----------------|
|     130 | null            |
|     125 | 130/            |
| 2820230 | 130/125/        |
| 4430546 | 130/125/        |
| 5497636 | 130/125/4430546 |
```
Which would allow for easy finding of common ancestors, but moving or removing
nodes becomes more complicated, and I wasn't sure of the performance of partial
string matching

I chose rails primarily due to familiarity and for ease of connecting and
managing a database. I tried an initial solution using sinatra and simple hash
tables to manage the data but decided that would likely not sufficiently meet
the requirements in spirit (enough ram would probably solve the problem, but
I'm assuming the problem statement is seeking a more robust answer)

### Caveats
I didn't explicitly handle error cases such as invalid trees. I had to draw the
line somewhere and cut scope.


## Original problem statement

Here's the code challenge.	It's designed	to test your decision making while trying to not write a lot of code or take a ton of time. That said, we do like to see clean, well organized

There's no set deadline,	take as much time as you think you need and just let me know when to expect it.

Our objective	is to assess how you think about, approach,	and solve novel problems,	so to the extent that you want to include a note about your thinking that you feel might not come through in the code, that helps us as well.


Thanks in advance!


We have an adjacency	list that creates	a tree of nodes where a child's parent_id	= a parent's	id. I have provided	some sample	data in the attached csv.

Please	make an api (rails,	sinatra,	cuba--your	choice)	that has two endpoints:

1) /common_ancestor	- It should	take two params,	a and b, and it should return	the root_id,	lowest_common_ancestor_id,	and depth of tree of the lowest	common	ancestor	that those two node ids share.


For example,	given the data for nodes:
id | parent_id
---------+-----------
125 | 130
130 | 
2820230	| 125
4430546	| 125
5497637	| 4430546


/common_ancestor?a=5497637&b=2820230	should	return
{root_id:	130, lowest_common_ancestor:	125, depth:	2 }

/common_ancestor?a=5497637&b=130	should	return
{root_id:	130, lowest_common_ancestor:	130, depth:	1}

/common_ancestor?a=5497637&b=4430546	should	return
{root_id:	130, lowest_common_ancestor:	4430546,	depth:	3}


if there is no common	node match,	return	null for all fields
/common_ancestor?a=9&b=4430546	should	return
{root_id:	null, lowest_common_ancestor:	null, depth:	null}

if a==b, it should	return	itself

/common_ancestor?a=4430546&b=4430546	should	return
{root_id:	130, lowest_common_ancestor:	4430546,depth 3}

1) /birds	- The second	requirement	for this project	involves	considering	a second	model,	birds.	Nodes have_many	birds and birds belong_to	nodes.	Our second	endpoint	should	take an array of node ids and return	the ids of the birds that belong	to one of those nodes or any descendant

The most efficient way to solve this problem probably	involves pre-processing	the data and then serving that pre-processed	data, but I would like you assume that a different process will add to the data (with no assumption	as to the magnitude	of the additions).	Your solution should be optimized	for a system that could expand to hundreds	of millions of records or maybe even billions of nodes.

At dataPlor we write software	that deals with exponentially	expanding	data. We are looking for people who can take novel problems,	demonstrate	first principles	design and performance	that flows from deep understanding,	and integrate	that into best practices	code quality and organization.
