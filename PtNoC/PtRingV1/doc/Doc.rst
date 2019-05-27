
1 Input Port & Output Port
****************************

1.1 Bypass Jump Protocol
=========================

1.1.1 Transmission Control Field
---------------------------------

- PktVld: Indecates whether there is a packet in the router.
- Arrival: Indecates whether it is the destination node.
- JumpStop: Indecates whether it is the longest node or not, if the packet does not arrive the destination node.
- JumpCnt: Jump counter. It is orginazed in one-hot code. If JumpCnt[0] is 1, only one node can be bypassed.
- NearDest: Indecates whether the packet will arrive destination node when JumpCnt[0]==1. 
  - If (JumpCnt[0]==1 & NearDest==1) Arrival=1; JumpStop=0; .
  - If (JumpCnt[0]==1 & NearDest==0) Arrival=0; JumpStop=1; .
- DestCnt: How many nodes are there before packet arrive the destination node.


All signals above and packet data are both inputs and outputs of each router.

aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

1.1 Bypass Jump Protocol
=========================

1.1.1 Transmission Control Field
---------------------------------

- PktVld: Indecates whether there is a packet in the router.
- Arrival: Indecates whether it is the destination node.
- JumpStop: Indecates whether it is the longest node or not, if the packet does not arrive the destination node.
- JumpCnt: Jump counter. It is orginazed in one-hot code. If JumpCnt[0] is 1, only one node can be bypassed.
- NearDest: Indecates whether the packet will arrive destination node when JumpCnt[0]==1. 
  - If (JumpCnt[0]==1 & NearDest==1) Arrival=1; JumpStop=0; .
  - If (JumpCnt[0]==1 & NearDest==0) Arrival=0; JumpStop=1; .
- DestCnt: How many nodes are there before packet arrive the destination node.


All signals above and packet data are both inputs and outputs of each router.


