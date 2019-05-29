
1 Input Port & Output Port
****************************

1.1 Bypass Jump Protocol
=========================

1.1.1 Transmission Control Field
---------------------------------

- pktVld: Indecates whether there is a packet in the router.
- arrival: Indecates whether it is the destination node.
- jumpStop: Indecates whether it is the longest node or not, if the packet does not arrive the destination node.
- jumpCnt: Jump counter. It is orginazed in one-hot code. If jumpCnt[0] is 1, only one node can be bypassed.
- nearDest: Indecates whether the packet will arrive destination node when jumpCnt[0]==1. 
  - If (jumpCnt[0]==1 & NearDest==1) arrival=1; jumpStop=0; .
  - If (jumpCnt[0]==1 & NearDest==0) arrival=0; jumpStop=1; .
- destCnt: How many nodes are there before packet arrive the destination node.


All signals above and packet data are both inputs and outputs of each router.

