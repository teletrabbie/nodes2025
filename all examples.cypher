// Basic Data model

CREATE (Substance)<-[:HAS_ATC]-(Medicament)-[:HAS_PRICE]->(Package),
(Medicament)-[:INDICATED]->(Indication);



// Example 1: graph algorithms and shortest path do not work with "common" nodes instead of attributes

// Create data with application/unit as own label
MERGE (n:Application {Code: 'IV'}) SET n.Description = 'intravenous';
MERGE (n:Application {Code: 'O'}) SET n.Description = 'oral';
MERGE (n:Unit {Code: 'mg'}) SET n.Description = 'milligramm';

MERGE (n:Substance {Code: 'L04AX06'});
MERGE (n:Substance {Code: 'L01FX15'});

MERGE (n:Medicament {Name: 'blenrep'});
MERGE (n:Medicament {Name: 'imnovid'});

MERGE (n:Indication {Name: 'multiple myeloma'});


// Create the relationships between the nodes
MATCH (s:Substance {Code: 'L04AX06'})
MATCH (u:Unit {Code: 'mg'})
MERGE (s)-[:HAS]->(u)
;

MATCH (s:Substance {Code: 'L04AX06'})
MATCH (a:Application {Code: 'O'})
MERGE (s)-[:HAS]->(a)
;

MATCH (s:Substance {Code: 'L04AX06'})
MATCH (m:Medicament {Name: 'imnovid'})
MERGE (m)-[:HAS_ATC]->(s)
;

MATCH (m:Medicament {Name: 'imnovid'})
MATCH (i:Indication {Name: 'multiple myeloma'})
MERGE (m)-[:INDICATED]->(i)
;

MATCH (s:Substance {Code: 'L01FX15'})
MATCH (u:Unit {Code: 'mg'})
MERGE (s)-[:HAS]->(u)
;

MATCH (s:Substance {Code: 'L01FX15'})
MATCH (a:Application {Code: 'IV'})
MERGE (s)-[:HAS]->(a)
;

MATCH (s:Substance {Code: 'L01FX15'})
MATCH (m:Medicament {Name: 'blenrep'})
MERGE (m)-[:HAS_ATC]->(s)
;

MATCH (m:Medicament {Name: 'blenrep'})
MATCH (i:Indication {Name: 'multiple myeloma'})
MERGE (m)-[:INDICATED]->(i)
;


// Add the data as attribute to the nodes and delete common lables (but also see example Arrays)
MATCH (n:Substance)-[:HAS]->(u:Unit) SET n.Unit = u.Code;
MATCH (n:Substance)-[:HAS]->(a:Application) SET n.Application = a.Code;

MATCH (n:Application) DETACH DELETE n;
MATCH (n:Unit) DETACH DELETE n;



// Example 2: n:m tables from RDBMS as relation in graphs

// Create nodes
WITH 'https://raw.githubusercontent.com/teletrabbie/nodes2025/refs/heads/main/import/case.csv' AS import
LOAD CSV WITH HEADERS FROM import AS row FIELDTERMINATOR ';'
MERGE (n:Case {Patient: row.patient_id})
  SET n.Discharge = date(row.discharge),
      n.id = toInteger(row.id)
;

WITH 'https://raw.githubusercontent.com/teletrabbie/nodes2025/refs/heads/main/import/substance.csv' AS import
LOAD CSV WITH HEADERS FROM import AS row FIELDTERMINATOR ';'
MERGE (n:Substance {Code: row.atc_code})
  SET n.id = toInteger(row.id)
;

// create relationship between the nodes instead of using n:m tables
WITH 'https://raw.githubusercontent.com/teletrabbie/nodes2025/refs/heads/main/import/case_substance.csv' AS import
LOAD CSV WITH HEADERS FROM import AS row FIELDTERMINATOR ';'
MATCH (c:Case {id: toInteger(row.case_id)})
MATCH (s:Substance {id: toInteger(row.substance_id)})
MERGE (s)-[:APPLIED {dose: toInteger(row.dose)}]->(c) 
;

// Show graph
MATCH (c:Case)
OPTIONAL MATCH (s:Substance)-[a:APPLIED]->(c)
RETURN *
;


// Example: Arrays

// Create nodes with numeric DDD (definded daily dose) and one with an array
MERGE (n:Substance {Code: 'L04AX06'}) SET n.DDD = 3, n.application = 'O';
MERGE (n:Substance {Code: 'B01AC21'}) SET n.DDD = 4.3;

// Creating "two" rows/nodes is not possible, because SET add/updates the attributs of the node
MERGE (n:Substance {Code: 'J01AA15'}) SET n.DDD = 0.3, n.application = 'O';
MERGE (n:Substance {Code: 'J01AA15'}) SET n.DDD = 0.1, n.application = 'P';

// It is easy/possible to persist arrays as arrays in the graph
MERGE (n:Substance {Code: 'J01AA15'}) SET n.DDD = [0.3,0.1], n.application = ['O','P'] ;

// If DDD is a array/list, first unwind (unnest) the elements and aggegrate the values
MATCH (n:Substance)
UNWIND(n.DDD) as ddd_without_array
RETURN n.Code, ddd_without_array;

MATCH (n:Substance)
UNWIND(n.DDD) as ddd_without_array
RETURN sum(ddd_without_array);



// Example: Indirect (calculated) relations

// Create data subset and relations
MERGE (n:Substance {Code: 'D07XB05'}) SET n.Description = 'dexamethasone';
MERGE (n:Substance {Code: 'D07CB04'}) SET n.Description = 'dexamethasone and antibiotics';
MERGE (n:Medicament {Name: 'Nystalocal, Crème'}) SET n.ATC = 'D07XB05', n.Admission = '38868';
MERGE (n:Package {Name: 'Nystalocal, Creme, 20 g'}) SET n.ATC = 'D07CB04', n.Admission = '38868', n.Price = 17;

MATCH (m:Medicament) 
MATCH (s:Substance) 
  WHERE m.ATC = s.Code
MERGE (m)-[:HAS_ATC]->(s);

MATCH (m:Medicament) 
MATCH (p:Package) 
  WHERE m.Admission = p.Admission
MERGE (m)-[:HAS_PRICE]->(p);

// Indirect relationship based on attributs of other nodes
MATCH (s:Substance)
MATCH (m:Medicament)-[:HAS_PRICE]->(p:Package)
  WHERE p.ATC = s.Code
  AND NOT EXISTS ((m)-[]->(s))
MERGE (m)-[:HAS_ATC {Source: 'Indirect'}]->(s);



// Example: Multiple node "layers"

// Create data like in Example "indirect relations"
MERGE (n:Substance {Code: 'D07XB05'}) SET n.Description = 'dexamethasone';
MERGE (n:Substance {Code: 'D07CB04'}) SET n.Description = 'dexamethasone and antibiotics';

// Create new label
MERGE (n:Substance {Code: 'D07CB04'}) SET n:`Expensive Drug List`;

// Create new node with new label
MERGE (n:`Expensive Drug List` {Code: 'B01AC11'}) SET n.Description = 'Iloprost';

// Set new node with "old" label
MATCH (n:`Expensive Drug List`) WHERE n.Code = 'B01AC11'
SET n:Substance;

// Possible solution: set attributes (and used rule-based formating)
MATCH (n:`Expensive Drug List`)
SET n.`Explore Flag` = 'On expensive drug list';
