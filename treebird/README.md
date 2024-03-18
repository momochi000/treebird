# README

## What is this

This is my solution to Dataplor's take home interview coding challenge.

## How to run it

If you have docker installed, from the parent directory, run `docker-compose
up`. That should build and install everything needed and run the local server.

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

I chose rails primarily due to familiarity and for ease of connecting and
managing a database. I tried an initial solution using sinatra and simple hash
tables to manage the data but decided that would likely not sufficiently meet
the requirements in spirit (enough ram would probably solve the problem, but
I'm assuming the problem statement is seeking a more robust answer)
