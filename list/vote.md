1. get qmtext
2. compute node_urn of the text
3. find providers qmtext
4. get /public/logs/{node_urn}-score.log

5. get /public/share/{node_urn}-score.json (mutable state)
6. vote ... 
7. update json (compute median)
8. add entry in {node_urn}-score.log
9. publish_root


