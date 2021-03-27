
digraph deps {
// direction Top Down:
"sorted list of nodes" -> list-label


}


where

peer: a keypair identifying a physical person
document: a piece of data created by a peer

grade: is an element of a ordered set of 21 values.
ranker: a peer who graded a document (type of peer)
editor: a peer who created a documents (type of peer)

editors-token-label: "I have submitted a proposal to Qmezgbyq...hJZ" (depends on PUBLICID: QmezgbyqFCEybpSxCtGNxfRD9uDxC53aNv5PfhB3fGUhJZ)
editors-token-nid: constant string (computed by hashing editors-token-label) ex: r1dm4qjb0srtx
editors-token-hash: hash of editors-token-nid ex: z6CfPrwfR1oK17V4vUhRL81jwN7QaGXfxrgQiQU4WRff 

node: hash of a document (qmhash)
short-hash: 12-character-substring of node (ex: QmXXXX...YYY)
document-key: string uniquely defining a document (concatenation of subject and short-hash)

node-urn: 13-character-token for the node (computed by hashing the string uri:ipfs:node)

list: set of nodes
list-label: a string referencing a list (ex: "Fair List")
list-token-lable: a unique strign derived from list-label (ex: "$editor_token_label for $list_label"
list-token-nid: 13 characters uniquely identifying a label (computed by hashing the uri:tree:label ex: 424lzkzs7q4ib)
list-token-hash: hash of list-token-nid ex: z6CfPsqy36qfM6p2mQp68Emp4qB8ziKXXhmdQotAmh3c
list-token = {list-token-label,list-token-nid,list-token-hash}


rankers-label: string referencing rankers of a node (derived from node-urn) ex: "I have ranked a proposal on 2masw23xbf4qy"
rankers-nid: a 13-character string derived from rankers-label
rankers-token-hash: hash of rankers-nid

editors: list of editors providing the editors-token's hash
rankers: list of ranked providing the rankers-token's hash

record: description of a ranking operations with timestamp and ranker identification and grade, (median is added for information)
        ex: "1614021178217:QmTeqJ...RwS 1614021178217 A QmTeqJutKAtVyX39qvhAGfjQFesbubamN8dvVPMg5jYRwS 6 5"
history: chronologic list of records for a given node along w/ auditing data (ex: /public/logs/2masw23xbf4qy-history.log )

median: median of set of all collected grades form history after uniquify and rankers verification
score: state of ranked node obtained by executing history and computing median (stores collected grades)
score-db: file corresponding to score ex: /public/logs/2masw23xbf4qy-state.json




