1. get qmtext
2. compute node_urn of the text
2. find providers qmtext
3. get /public/logs/{node_urn}-score.log

4. get /public/share/{node_urn}-score.json (mutable state)
5. vote ... 
6. update json (compute median)
7. add entry in {node_urn}-score.log
8. publish_root


