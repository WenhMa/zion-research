interface PtrNocRouterIf
#(JUMP_STEP  = "_",
  DATA_WIDTH = "_",
  NODE_NUM   = "_"
);

  typedef struct packed{
    logic arrival, nxtArrival, toNxtRouter, jumpStop, nearDest;
    logic [JUMP_STEP-2:0] jumpCnt;
  }typedef_JumpCtrl;
  typedef_JumpCtrl jumpCtrl;
  logic [$clog(NODE_NUM)-1:0] destCnt;
  logic [DATA_WIDTH-1:0] dat;

  logic localFul,routerFul;

  modport Send(input localFul, routerFul,
              output jumpCtrl, destCnt, dat
              );

  modport Receive (input jumpCtrl, destCnt, dat,
                  output localFul, routerFul
                  );

endinterface: PtrNocRouterIf

interface PtrNocLocalIf
#(DATA_WIDTH = "_",
  NODE_NUM   = "_"
);
  logic r2lPktVld, r2lRd, l2rWr, l2rFul;
  logic [DATA_WIDTH-1:0] r2lDat, l2rDat;
  logic [$clog(NODE_NUM)-1:0] destCnt;

  modport Router(input r2lRd, l2rWr, l2rDat, destCnt,
                output r2lPktVld, l2rFul, r2lDat
                );

  modport  LocalNode(input r2lPktVld, l2rFul, r2lDat
                    output r2lRd, l2rWr, l2rDat, destCnt,
                    );

endinterface: PtrNocLocalIf

module PtrRouter
(
  input clk,rst,
  PtrNocRouterIf.Send    bDatFromLast,
  PtrNocRouterIf.Receive bDat2Nxt,
  PtrNocLocalIf.Router   bLocalDat
);

  localparam DATA_WIDTH = $bits(bDatFromLast.dat);
  localparam DEST_ADDR_WIDTH = $bits(bDatFromLast.desCnt);
  localparam JUMP_STEP = $bits(bDatFromLast.jumpCnt)+1;
  typedef bDatFromLast.typedef_JumpCtrl typedef_JumpCtrl;
  typedef_JumpCtrl jumpJumpCtrl, bufJumpCtrl;
  logic rbufNotEmpty, l2rBufNotEmpty;
  logic [DEST_ADDR_WIDTH-1:0] rbufDestCnt, l2rBufDestCnt, bufDestCnt;
  logic [DATA_WIDTH-1:0] rbufDat, l2rBufDat, bufDat;

  // jump path.
  wire bothEmpty     = !rbufNotEmpty & !l2rBufNotEmpty;
  wire jumpNxtRbufEn = bothEmpty & !bDat2Nxt.routerFul & bDatFromLast.jumpCtrl.toNxtRouter;
  wire jumpNxtLbufEn = bothEmpty & !bDat2Nxt.localFul & bDatFromLast.jumpCtrl.nxtArrival;
  wire jumpEn        = jumpNxtRbufEn | jumpNxtLbufEn;
  assign jumpJumpCtrl.arrival     = bDatFromLast.jumpCtrl.nxtArrival;
  assign jumpJumpCtrl.nxtArrival  = bDatFromLast.jumpCtrl.jumpCnt[1] & bDatFromLast.jumpCtrl.nearDest;
  assign jumpJumpCtrl.toNxtRouter = !(bDatFromLast.jumpCtrl.jumpCnt[0] & bDatFromLast.jumpCtrl.toNxtRouter);
  assign jumpJumpCtrl.jumpStop    = bDatFromLast.jumpCtrl.jumpCnt[0] & !bDatFromLast.jumpCtrl.nearDest;
  assign jumpJumpCtrl.nearDest    = bDatFromLast.jumpCtrl.nearDest;
  assign jumpJumpCtrl.jumpCnt     = {1'b0,bDatFromLast.jumpCtrl.jumpCnt[JUMP_STEP-2:1]};

  // buffer path.
  wire rbufRd      = rbufNotEmpty & !bDat2Nxt.routerFul;
  wire l2rBufRdTmp = l2rBufNotEmpty & !bDat2Nxt.localFul;
  wire l2rBufRd    = l2rBufRdTmp & !rbufRd;
  wire bufRd       = rbufRd | l2rBufRdTmp;
  assign {bufDestCnt,bufDat} =  (rbufRd)? {rbufDestCnt,rbufDat} :
                                (l2rBufRdTmp)? {l2rBufDestCnt,l2rBufDat} : '0;
  assign bufJumpCtrl.arrival     = (bufDestCnt == $bits(bufDestCnt)'d1);
  assign bufJumpCtrl.nxtArrival  = (bufDestCnt == $bits(bufDestCnt)'d2);
  assign bufJumpCtrl.toNxtRouter = (bufDestCnt > $bits(bufDestCnt)'d1);
  assign bufJumpCtrl.jumpStop    = '0;
  assign bufJumpCtrl.nearDest    = (bufDestCnt <= JUMP_STEP) & (bufDestCnt != '0);
  assign bufJumpCtrl.jumpCnt[JUMP_STEP-2] = (!bufJumpCtrl.nearDest | (bufDestCnt==JUMP_STEP-2));
  for(genvar i=2;i<JUMP_STEP-2;i++)begin
    assign bufJumpCtrl.jumpCnt[i-2] = (bufDestCnt == i);
  end

  // output generate.
  assign bDat2Nxt.dat       = (jumpEn)? bDatFromLast.dat : bufDat;
  assign bDat2Nxt.destCnt   = (jumpEn)? bDatFromLast.desCnt : 
                              (!bufJumpCtrl.nearDest)? bufDestCnt-JUMP_STEP : '0;
  assign bDat2Nxt.jumpCtrl  = (jumpEn)? jumpJumpCtrl : bufJumpCtrl;

  // buffers.
  wire rbufWr  = ((rbufNotEmpty | l2rBufNotEmpty) & (|bDatFromLast.jumpCtrl.jumpCnt)) 
                | bDatFromLast.jumpCtrl.jumpStop;
  TwoRegFifo  U_RouterBuf(
                .clk,
                .rst,
                .iWrEn(rbufWr),
                .iWrDat({bDatFromLast.destCnt, bDatFromLast.dat}),
                .iRdEn(rbufRd),
                .oFul(bDatFromLast.routerFul),
                .oNotEmpty(rbufNotEmpty),
                .oRdDat({rbufDestCnt,rbufDat})
              );

  TwoRegFifo  U_R2lBuf(
                .clk,
                .rst,
                .iWrEn(bDatFromLast.arrival),
                .iWrDat(bDatFromLast.dat),
                .iRdEn(bLocalDat.r2lRd),
                .oFul(bDatFromLast.localFul),
                .oNotEmpty(bLocalDat.r2lPktVld),
                .oRdDat(bLocalDat.r2lDat)
              );

  TwoRegFifo  U_L2RBuf(
                .clk,
                .rst,
                .iWrEn(bLocalDat.l2rWr),
                .iWrDat({bLocalDat.destCnt,bLocalDat.l2rDat}),
                .iRdEn(l2rBufRd),
                .oFul(bLocalDat.l2rFul),
                .oNotEmpty(l2rBufNotEmpty),
                .oRdDat({l2rBufDat,l2rBufDat})
              );

  defparam U_RouterBuf.WIDTH = $bits(bDatFromLast.destCnt) + $bits(bDatFromLast.dat);
  defparam U_R2lBuf.WIDTH = $bits(bLocalDat.r2lDat);
  defparam U_L2RBuf.WIDTH = $bits(bLocalDat.destCnt) + $bits(bLocalDat.l2rDat);


endmodule: PtrRouter
