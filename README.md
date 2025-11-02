# Attachments of my Nodes 2025 session

In this repository you will find the cypher queries of my examples, tha data for example 2 and the slides of the NODES 2025 session "Knowledge Graph of Drugs Data for Swiss Healthcare System". The goal of my session was to give "tipps and tricks" to other graph beginners for your (first) knowledge graph.

## General

* Easiest start: Neo4j Desktop
* If you need to share your graph, use the free Aura DB (limit: 200’000 nodes and 400’000 relations)
* Prepare yourself with free Neo4j GraphAcademy
* Do project management, requirement engineering and talk with your stakeholders
* Start with the data that you are familiar with
  * Keep it simple at the beginning and extend later
  * Split the cypher code in logic parts
* Change your way of thinking: graphs work different in comparison to RDBMS

## Data modeling

* Be careful with transferring “hierarchy” or “dimension tables” from RDBMS to graphs: probably better use attributes and not lables
* In graphs you can create edges instead of n:m tables (and you can anylse clusters easyly)
* Arrays are normal in graphs and not the exception (“forget” 3NF or BCNF)
* Flexible relationships in graphs are useful, especially if there is “tidy” data in your source
* Store important codes as attribute in the nodes, so that you can “recycle” them

## Data visualisation

* Bloom/Explore offers a lot of individual solutions with saved cyphers, colors, symbols, sizes etc.
* Don’t use version numbers for important perspectives in Bloom/Explore (otherwise you probably must change deeplinks in other applications everytime you deploy a new version)
