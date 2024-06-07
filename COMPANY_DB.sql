/* PROJECT IN MYSQL  
As a data analyst in a startup supplier company in Accra-Ghana, my task is to create a simple database for current employees, branches, clients and supply types.
The database should contain basic employee details and the branches and clients they work and relate with.
*/


CREATE TABLE Employee(
	emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    birth_date DATE NOT NULL,
    sex CHAR(1) NOT NULL,
    salary VARCHAR(10) NOT NULL,
    super_id INT,
    branch_id INT
);
INSERT INTO Employee VALUES 
(100,'Frank','Idan','2000-09-04','M','34,000',NULL,NULL),
(101,'Nadia','Shingra','1999-11-04','F','70,000',100,1),
(102,'Fido','Eddie','2003-09-30','M','45,000',100,2),
(103,'Emma','Adnell','2002-02-17','M','50,000',102,2),
(104,'Valerie','Ridley','2000-01-02','F','30,000',102,2),
(105,'Francisca','Tomson','2001-05-20','F','40,000',100,3),
(106,'Tom','Hansen','1999-07-22','M','60,000',106,3),
(107,'Bern','Essiamah','2000-03-03','M','65,000',106,3);

SELECT * FROM Employee;
-- DROP TABLE Employee

ALTER TABLE Employee
ADD CONSTRAINT FK_EmployeeBranch_superID_mgrID  # created a foreign_key NAME
FOREIGN KEY(super_id) REFERENCES Branch(mgr_id) ON DELETE SET NULL; 

SET FOREIGN_KEY_CHECKS = 1;   -- set to 0 disables a foreign key temporarily, set to 1 re-enables the foreign key

-- ALTER TABLE Employee DROP CONSTRAINT FK_EmployeeBranch_superID_mgrID;

/* ALTER TABLE Employee 
ADD CONSTRAINT FK_EmployeeBranch_branchID  
FOREIGN KEY(branch_id) REFERENCES Branch(branch_id) ON DELETE SET NULL;  */  

-- ALTER TABLE Employee DROP CONSTRAINT FK_EmployeeBranch_branchID;

-- UPDATE Employee SET branch_id =2 WHERE emp_id = 101;
-- UPDATE Employee SET first_name = 'Frank' WHERE emp_id= '102';
 

/* SELECT * FROM Employee ORDER BY salary DESC; --order by salary
SELECT * FROM Employee ORDER BY sex,first_name,last_name; -- order by sex and name

SELECT first_name AS forename, last_name AS surname  -- AS keyword changes column name
FROM Employee 
ORDER BY first_name,last_name;

SELECT COUNT(sex) FROM Employee WHERE sex = 'F';  -- displays the number of females in the company
SELECT SUM(salary) FROM Employee;  -- calculate the sum of salary

SELECT * 
FROM Employee 
WHERE birth_date LIKE '2000%';  -- displays employees born in 2000 (LIKE OPERATOR)
# WHERE birth_date LIKE '____-09%';  -- SQL Wildcard, displays employees born in September    */


CREATE TABLE Branch(
	branch_id INT PRIMARY KEY,
    branch_name VARCHAR(20), 
    mgr_id INT,
    mgr_start_date DATE
   -- FOREIGN KEY(mgr_id) REFERENCES Employee(emp_id) ON DELETE SET NULL
); 

/* Altering the table to add a foreign key
ALTER TABLE Branch
ADD CONSTRAINT FK_Branch_Employee  --constraint name(two tables being referenced)
FOREIGN KEY (mgr_id) REFERENCES Employee(emp_id)    */

INSERT INTO Branch VALUES
(1,'Tema',100,'2006-02-09'),
(2,'Accra',102,'2005-01-25'),
(3,'Kumasi',NULL,'2008-06-09'),
(4,'Cape',NULL,NULL);
         
UPDATE Branch SET mgr_id = 106 WHERE branch_name = 'Kumasi';

SELECT * FROM Branch;
-- SELECT * FROM Branch WHERE mgr_start_date > '2006-01-01';  -- selects date above 2006
-- SELECT COUNT(branch_id) FROM Branch WHERE mgr_start_date > '2007-01-01';  -- count the number of branches above 2007 date


CREATE TABLE Client(
	client_id SERIAL PRIMARY KEY,
    client_name VARCHAR(30),
    branch_id INT
    -- CONSTRAINT FK_ClientBranch FOREIGN KEY(branch_id) REFERENCES Branch(branch_id)
);

/* Altering existing table to add a foreign key
ALTER TABLE Client
ADD CONSTRAINT FK_Client_Branch          --constraint name(two tables being referenced)
FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)   */

SELECT * FROM Client;

UPDATE Client
SET client_name = CASE
    WHEN client_id = 400 THEN 'Embassy'
    WHEN client_id = 401 THEN 'Accra Mall'
    WHEN client_id = 402 THEN 'Standard Bank'
    WHEN client_id = 403 THEN 'KNUST'
    WHEN client_id = 404 THEN 'High School'
    WHEN client_id = 405 THEN 'West Hills Mall'
    -- Add more WHEN clauses for other client_ids as needed
    ELSE client_name
END;

-- SELECT * FROM Client WHERE client_name LIKE '%all%'; -- SQL WILDCARD,displays the values having 'all' in them


CREATE TABLE Works_With(
	emp_id INT,
    client_id INT,
    total_sales INT,
    PRIMARY KEY(emp_id,client_id)
    -- FOREIGN KEY(emp_id) REFERENCES Employee(emp_id),
    -- FOREIGN KEY(client_id) REFERENCES Client(client_id)
);

INSERT INTO Works_With VALUES 
(105,400,90000),
(106,402,50000),
(107,402,100000),
(107,405,65000),
(101,404,75000),
(102,401,95000),
(104,403,100000),
(103,401,45000),
(100,404,45000);
SELECT * FROM Works_With;

-- UPDATE Works_With SET client_id = 403 WHERE emp_id = 100;

/* Altering existing table to add 2 foreign keys
ALTER TABLE Works_With
ADD CONSTRAINT FK_WorksWith_Client          --constraint name(two tables being referenced)
FOREIGN KEY(client_id) REFERENCES Client(client_id),  
ADD CONSTRAINT FK_WorksWith_Employee        --constraint name(two tables being referenced)
FOREIGN KEY(emp_id) REFERENCES Employee(emp_id);     */


CREATE TABLE Branch_Supplier(
	branch_id INT,
    supplier_name VARCHAR(30),
    supply_type VARCHAR(30),
    PRIMARY KEY(branch_id,supplier_name)
    -- FOREIGN KEY(branch_id) REFERENCES Branch(branch_id) ON DELETE CASCADE
);

INSERT INTO Branch_Supplier VALUES 
(2,'Wale Paper','Paper'),
(1,'Special Gobe','Beans'),
(2,'The Jollof','Jollof Rice'),
(3, 'Salamatu Bruks','Brukina'),
(3,'Tiger Nut','Milk'),
(1,'Special bar','Fufu'),
(1,'Hajia Waakye','Waakye'),
(2,'Pocolee banku','Banku');
SELECT * FROM Branch_Supplier;


-- SQL UNIONS             --combines the results of 2 or more SELECT statements in ONE result
SELECT first_name AS Company_Name FROM Employee 
UNION
SELECT branch_name FROM Branch
UNION
SELECT client_name FROM Client;

SELECT salary FROM Employee
UNION
SELECT total_sales FROM Works_With; 


-- SQL JOINS
-- JOINING 2 TABLES (EMPLOYEE & BRANCH)                 
SELECT e.emp_id,e.first_name,e.last_name,e.salary,b.branch_name
FROM Employee e
INNER JOIN Branch b   -- INNER JOIN prioritizes ALL tables and selects matching values in these tables 
					-- RIGHT JOIN Branch -- RIGHT JOIN prioritizes rows from right table and selects matching values from the left table
					-- LEFT JOIN Branch -- LEFT JOIN prioritizes rows from left table and selects matching values from the right table
ON e.emp_id = b.mgr_id;
-- WHERE Employee.salary > '40000'   --outputs only the employes with salary more than '40,000'


-- JOINING 2 TABLES (CLIENT & WORKS_WITH)
SELECT cl.client_name,cl.branch_id,w.emp_id,w.total_sales
FROM client cl
INNER JOIN works_with w
ON cl.client_id = w.client_id;

-- JOINING 3/MORE TABLES (EMPLOYEE, BRANCH, CLIENT & BRANCH SUPPLIER)
SELECT Employee.emp_id,Employee.first_name,Employee.last_name,Branch.branch_name,Branch_Supplier.supplier_name,Branch_Supplier.supply_type,Client.client_name
FROM Employee
INNER JOIN Branch ON Employee.emp_id = Branch.mgr_id    
INNER JOIN Client ON Branch.branch_id = Client.branch_id
INNER JOIN Branch_Supplier ON Branch.branch_id = Branch_Supplier.branch_id
