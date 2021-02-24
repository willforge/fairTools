## voting process :

1. get qmtext (hash of the text from [fair-list.log][5])
2. compute node_urn of the text
3. find providers qmtext
4. get [/public/logs/{node_urn}-history.txt][1]

5. get [/public/logs/{node_urn}-state.json][2] (mutable state)
6. vote ... 
7. update {node_urn}-state.json (compute median)
8. add entry in {node_urn}-history.txt
9. merge /public/logs/{node_urn}-state.txt w/ [/public/share/{node_urn}-result.json][3]
10. publish_root


node_urn = nid(`uri:ipfs:${qmtext}`); ex: [2masw23xbf4qy][4]


[1]: http://127.0.0.1:8080/ipfs/Qmb3cY3zFJ5isjJ5H9cP47Vfqa6pqNwypbuo2TiBGjUmLd/#/files/public/logs/2masw23xbf4qy-history.txt
[2]: http://127.0.0.1:8080/ipfs/Qmb3cY3zFJ5isjJ5H9cP47Vfqa6pqNwypbuo2TiBGjUmLd/#/files/public/logs/2masw23xbf4qy-state.json
[3]: http://127.0.0.1:8080/ipfs/Qmb3cY3zFJ5isjJ5H9cP47Vfqa6pqNwypbuo2TiBGjUmLd/#/files/public/share/2masw23xbf4qy-result.json
[4]: http://127.0.0.1:8080/ipfs/QmQ6gFoR82VqvQ5YfSBAEw1ypHcYnS28gLTxhzzAwnF6MV
[5]: http://127.0.0.1:8080/ipfs/Qmb3cY3zFJ5isjJ5H9cP47Vfqa6pqNwypbuo2TiBGjUmLd/#/files/public/logs/fair-list.log


# glossary:

- score_db: 
   The state of median computation in json format (including all scores weights)
   ex: [2masw23xbf4qy-state.json](http://127.0.0.1:8080/ipfs/QmS5R793TDD32fmyMrLV3r831d8G4UywZRLAAWm1np467c/2masw23xbf4qy-state.json)
- history_db
   The paper trail of all casted votes (list)
   ex: [2masw23xbf4qy-history.txt](http://127.0.0.1:8080/ipfs/QmS5R793TDD32fmyMrLV3r831d8G4UywZRLAAWm1np467c/2masw23xbf4qy-history.txt)

     
