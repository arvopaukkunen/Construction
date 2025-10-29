CREATE TABLE employees(
   id INT PRIMARY KEY,
   name VARCHAR(255) NOT NULL,
   age INT NOT NULL,
   salary DECIMAL(10,2) NOT NULL,
   bonus DECIMAL(10,2) DEFAULT 0
);

INSERT INTO employees(id, name, age, salary)
VALUES(1, 'Jane Doe', 25, 120000);

Select * from employees e 

INSERT INTO employees(id, name, age, salary)
VALUES (1, 'Jane Smith', 26, 130000)

AS new
ON DUPLICATE KEY UPDATE
   name = new.name,
   age = new.age,
   salary = new.salary;

INSERT INTO employees(id, name, age, salary)
VALUES(1, 'Jane Doe', 26, 140000)
AS new
ON DUPLICATE KEY UPDATE
   salary = new.salary,
   bonus = new.salary * 0.1;
-------------
CREATE TABLE t (a SERIAL, b BIGINT NOT NULL, UNIQUE KEY (b));;
INSERT INTO t VALUES ROW(1,1), ROW(2,2);
TABLE t;

INSERT INTO t VALUES ROW(2,3), ROW(3,3) ON DUPLICATE KEY UPDATE a=a+1, b=b-1;

select * from t
-------------------
CREATE TABLE geek_demo
(
id INT AUTO_INCREMENT PRIMARY KEY, 
name VARCHAR(100) 
);

INSERT INTO geek_demo (name)
VALUES('Neha'), ('Nisha'), ('Sara') ;

select * from geek_demo

INSERT INTO geek_demo(name) 
VALUES ('Sneha') 
ON DUPLICATE KEY UPDATE name = 'Sneha';

INSERT INTO geek_demo (id, name) 
VALUES ( 'Mona')
ON DUPLICATE KEY UPDATE name = 'Mona2';