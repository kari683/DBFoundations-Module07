# Assignment 7 - Written Summary for Week 7
**Dev:** Kari Brothers  
**Date:** August 23, 2020  
Foundations of Databases Class

https://github.com/kari683/DBFoundations-Module07

# All About SQL Functions

## Introduction
This paper provides an overview of various SQL functions.

## SQL UDF
A UDF or “User Defined Function” is a custom function created by the designer and can be used in addition to built-in SQL functions.  A UDF is similar to using a view with a Where clause.

## A Different Day, A Different Function
A scalar function is one that returns a single value as an expression. If you use a scalar function is a table, it will be applied to each row.
An inline function is similar to a view – it can only contain a single Select statement and the columns define the columns of the returned table. (https://sqlsunday.com/2013/05/05/table-value-vs-inline-table-functions/, 2020)
A multi-statement function can consist of multiple statements that are stored in a return variable. The return variable is defined at the top of the function and this specifies the structure of the return table. (https://database.guide/introduction-to-multi-statement-table-valued-functions-mstvf-in-sql-server/, 2020)
The differences between an inline function and a multi-statement functions are outlined here: https://database.guide/difference-between-multi-statement-table-valued-functions-inline-table-valued-functions-in-sql-server/

## Summary
This paper provided an overview of UDFs, scalar, inline and multi-statement functions.
