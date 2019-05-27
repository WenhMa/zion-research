module TwoRegFifoTb;

  logic clk,rst;
  initial
    forever clk = ~clk;
  initial begin
    rst = 0;
    #100 rst = 1;
  end

  logic       ful,empty,wrEn,rdEn;
  logic [1:0] datVld;
  logic [7:0] wrDat,rdDat;

  initial begin
    wrDat = 0;
    @(posedge rst)
    forever @(negedge clk) wrDat = wrDat + 1 ; 
  end

  initial begin
    wrEn = 0;
    rdEn = 0;
  end

  TwoRegFifo  U_TwoRegFifo(
                .clk,
                .rst,
                .iWrEn(wrEn),
                .iWrDat(wrDat),
                .iRdEn(rdEn),
                .oFul(ful),
                .oEmpty(empty),
                .oDatVld(datVld),
                .oRdDat(rdDat)
  );

  defparam U_TwoRegFifo.WIDTH = 8;

  task WrTask;
    if(!ful) begin
      wrEn = 1;
    end
  endtask

  task RdTask;
    if(!empty) begin
      rdEn = 1;
    end
  endtask

  initial begin
    $fsdbDumpfile("tb.fsdb")
    $fsdbDumpvars();
  end

endmodule
