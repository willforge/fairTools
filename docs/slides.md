












# fairTools (technical overview)

by [fairfriends@protonmail.com](mailto:fairfriends@protonmail.com)


## fairTools 
 
   - is a set of tools to make collaborative technologies accessible to anyone
   - it consists of 
      - a text editor ( [fairPad][1] )
      - a immutable repository (fairStore)
      - a document broadcast network (fairNet)
      - a network registration tool (fairFriends)

[1]: https://duckduckgo.com/?q=fairPad+!g


## fairTools (Cont.)

   - a decision making tools (fairVote)
   - a mutable naming system (fairName)
   - a ledger to seal decisions (fairRing)
   - a privacy layer (sealed envelops) (fairToken)
   - keys and identities managment tool ( [fairKey][1] & [fairID][2] )

[1]: https://duckduckgo.com/?q=fairKey+!g
[2]: https://duckduckgo.com/?q=fairID+!g


## Problem to be solved : 

   - reach agreement on an area of improvement and propose solutions
   - aggregate and consolidate common will on a specific topic
   - distribute drafts to the complete network
   - globally rank documents 
   - reach a consensus within the network
   - publish official winning document
  

## Artificial Legislator

- required properties :
  1. objectivity (no emotions)
  2. common will awareness
  3. spatio-temporal invariance / ubiquity (immutability ?)

- AI based


## Our approach

  - P2P network for collaborative writing
  - use of asynchronous collaborative pad ([fairPad](https://duckduckgo.com/?q=fairPad+!g))
  - all submissions are kept anonymous (guarantee of freedom w/o consequence)


## Anonymity

  - communication on a pull-only architecture
  - posts are made to a public address via the network itself,
    without ability to trace back original submitter.
  - never publish under your own identity,  one needs to obtain a sealed envelop prior publication


## How a post is conducted 

  process:
   - add document to CAS network. 
   - optionally upload document to an anonymous *CAS* server via a (secure) OOB channel
   - be silent for a while ( the time it percolates to anonymous places via gossip)
   - ask some peers to peek at your document and sync'up theirs (using TLS)

   - and pin via an "anonymous" pinata (over fairToken, which is equivalent to an "internal" TOR)



## Asynchronous collaboration

- requires merge of substantial differences in versions (diff3)
- allow network resilience
- gives time to revise documents



## Document Flow 

 - documents are locally added to a "tree" of documents.
 - documents are locally ordered by personal preference (according to a common will criteria)
 - documents are submitted to the network by insertion to a global DAG


## Document Flow (cont.)

 - any member is randomly checking for new document upon connection
   and synchronized with their local version of the dag

 - the global DAG is obtain by running a "tree-median" algorithm on the ranking of each local DAGs



## Median Algorithm

- median allow to guarantee parametric threshold of member agreed on the outcome.
- ex: more than 60% of the group agree to the document xyz




## Used technologies


- [GIT][4]  : versioning of mutable
- [IPFS][5] : CAS Network (immutable)
- [fairName][6] : mutable broadcast
- [fairRing][7] : ledger / blockring
- [fairToken][8] : privacy layer
- [fairkeys][9] : GnuPG (+keybase)


[4]: https://willforge.github.io/fairTools/
[5]: https://www.ipfs.io
[6]: https://duckduckgo.com/?q=fairName+!g
[7]: https://duckduckgo.com/?q=fairRing+!g
[8]: https://duckduckgo.com/?q=fairToken+!g
[9]: https://duckduckgo.com/?q=fairKeys+!g


## fairToken

- a set of unique peerkeys are exchanged among member before any publications
- peerkeys are managed via power-of-attorney attached to each keys.
- (non-duplication of token, double-spending etc.)
 

## Glossary 

- OOB = Out of band
- CAS = content addressable store
- CAS = content addressed storage
- CID = content identify
- DAG = direct acyclic graph











  Reveal.initialize({ transition: 'none' });


  window.Reveal.initialize({
    plugins: [ RevealMarkdown ]
  });





