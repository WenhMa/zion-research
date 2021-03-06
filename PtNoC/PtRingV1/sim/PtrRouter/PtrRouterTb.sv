
module PtrRouterTb;

  localparam JUMP_STEP  = 4;
  localparam DATA_WIDTH = 128;
  localparam NODE_NUM   = 32;
  logic clk,rst;
  PtrNocRouterIf inputIf(),outputIf();
  PtrNocLocalIf localIf();

  PtrRouter U_PtrRouter(
              .clk,
              .rst,
              .bDatFromLast(inputIf.Receive),
              .bDat2Nxt(outputIf.Send),
              .bLocalDat(localIf.Router)
            );

  initial begin
    InputIfClr();
    OutputIfClr();
    LocalIfClr();
  end

  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
  initial begin
    rst = 0;
    #100 rst = 1;
  end

  initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,PtrRouterTb,"+all");
    #300000;
    $finish();
  end



  defparam inputIf.JUMP_STEP   = JUMP_STEP;
  defparam outputIf.JUMP_STEP  = JUMP_STEP;
  defparam inputIf.DATA_WIDTH  = DATA_WIDTH;
  defparam outputIf.DATA_WIDTH = DATA_WIDTH;
  defparam localIf.DATA_WIDTH  = DATA_WIDTH;
  defparam inputIf.NODE_NUM    = NODE_NUM;
  defparam outputIf.NODE_NUM   = NODE_NUM;
  defparam localIf.NODE_NUM    = NODE_NUM;

  task InputIfClr;
    inputIf.jumpCtrl  = '0;
    inputIf.destCnt   = '0;
    inputIf.dat       = '0;
  endtask: InputIfClr

  task OutputIfClr;
    outputIf.jumpCtrl = '0;
    outputIf.destCnt  = '0;
    outputIf.dat      = '0;
  endtask: OutputIfClr

  task LocalIfClr;
    localIf.r2lRd     = '0; 
    localIf.l2rWr     = '0;
    localIf.l2rDat    = '0; 
    localIf.destCnt   = '0;
  endtask: LocalIfClr

endmodule: PtrRouterTb
