
module PtrRouterTb;

  logic clk,rst;
  PtrNocRouterIf inputIf(),outputIf();
  PtrNocLocalIf localIf();

  PtrRouter U_PtrRouter(
              .clk,
              .rst,
              .bDatFromLast(inputIf.receive),
              .bDat2Nxt(outputIf.Send),
              .bLocalDat(localIf.Router)
            );

  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
  initial begin
    rst = 0;
    inputIf.jumpCtrl  = '0;
    inputIf.destCnt   = '0;
    inputIf.dat       = '0;
    outputIf.jumpCtrl = '0;
    outputIf.destCnt  = '0;
    outputIf.dat      = '0;
    localIf.r2lRd     = '0; 
    localIf.l2rWr     = '0;
    localIf.l2rDat    = '0; 
    localIf.destCnt   = '0;
    
    #100 rst = 1;
  end

  defparam inputIf.JUMP_STEP   = 4;
  defparam outputIf.JUMP_STEP  = 4;
  defparam inputIf.DATA_WIDTH  = 128;
  defparam outputIf.DATA_WIDTH = 128;
  defparam localIf.DATA_WIDTH  = 128;
  defparam inputIf.NODE_NUM    = 128;
  defparam outputIf.NODE_NUM   = 128;
  defparam localIf.NODE_NUM    = 128;


endmodule: PtrRouterTb
