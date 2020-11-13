<meta charset="utf8"/>
<style> img { max-width:calc(100vw - 3rem) ; margin: auto; } </style>

# median on a tree

For a majority judgment vote, we need to compute median of all grades for each candidate,
this required lots of network access when done over a P2P network

We implemented a "tree" algorithm that uses only local resources to compute a median over a DAG tree !

## example: set of 26 elements

   ``set:    3, 7, 6, 5, 5,10, 1,10, 6,13, 3,10, 3,13, 3, 7, 3, 5, 6, 9, 6, 9,11, 7,12,10``

## median is 6.50


```
n: 26
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
set:    3, 7, 6, 5, 5,10, 1,10, 6,13, 3,10, 3,13, 3, 7, 3, 5, 6, 9, 6, 9,11, 7,12,10
soidx:  6, 0,10,12,14,16, 3, 4,17, 2, 8,18,20, 1,15,23,19,21, 5, 7,11,25,22,24, 9,13
nodes:  6,10,12,16, 0,14,17, 4, 3,20,18, 8, 2,23,15, 1,21,19,25,11, 7, 5,22,24,13, 9
values: 1, 3, 3, 3, 3, 3, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 9, 9,10,10,10,10,11,12,13,13
list:   1, 3, 3, 3, 3, 3, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 9, 9,10,10,10,10,11,12,13,13
                                             ^
min: n6:1 (1*)
max: n9:13 (13*)
m-: n2=6 (6*)
m+: n23=7 (7*)
tree median: 6.50 <----- 
```

![tree26](tree.png)