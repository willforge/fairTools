#

Pad: <https://mensuel.framapad.org/p/fairPad>

 Transparent Topology ...

- ring of friend can organically be set (spontaneous registrations)
- need link to random link to nodes in the "broader" network  (in order to benefit from the "small-world" connectivity model)

communication is both way if both parties know their respective peerids (i.e. the have registered eachother as trusted friends)
you can ONLY receive messages from the other peerid you collected form the networkd ("random pull" )

The exchanges of data is what makes it available on the network, for other people tools to process the information

All public communication are forbiden, solely DM/PM are allowed...



## Network Charter (Membership)

each person who register to the transparent network has to sign the organization charter
the charter is a "legal" text that define the proper use of the network and is the SAME for everyone 
therefore is has a "constant" hash (SHA256 = QmaeiKYDCmndBprGxs89tMrCRabDnV9te7dKPRK4U2JVg9).
signing means putting a pin on this hash 

all "signed" charter copies are "immutable" and can be used to identify peers and bind people to a "minimal" social contract ... 

discovery is done w/ a findprovs command :
    ```
    ipfs dht findprovs QmaeiKYDCmndBprGxs89tMrCRabDnV9te7dKPRK4U2JVg9
    ```
    
it returns all the public peerids of nodes who host the content :
      https://gateway.ipfs.io/ipfs/QmaeiKYDCmndBprGxs89tMrCRabDnV9te7dKPRK4U2JVg9
      ou
      https://cloudflare-ipfs.com/ipfs/QmaeiKYDCmndBprGxs89tMrCRabDnV9te7dKPRK4U2JVg9
      ou
      https://ipfs.blockringtm.ml/ipfs/QmaeiKYDCmndBprGxs89tMrCRabDnV9te7dKPRK4U2JVg9
      ou
      https://gateway.pinata.cloud/ipfs/QmaeiKYDCmndBprGxs89tMrCRabDnV9te7dKPRK4U2JVg9

once you have Peerid you can check /my/identity/public.yml or can send a "poke" via the biff notification etc...




