module TwoRegFifoTb;

  logic clk,rst;
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
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
    #200;
    // full vector
    @(negedge clk);
    WrTask;      
    @(negedge clk);
    WrTask;      
    // empty vector
    @(negedge clk);
    wrEn = 0;
    rdEn = 0;
    @(negedge clk);
    @(negedge clk);
    wrEn = 0;
    rdEn = 0;
    RdTask;      
    @(negedge clk);
    wrEn = 0;
    rdEn = 0;
    RdTask;      
    // 1 wr, 1 rd vector
    @(negedge clk);
    wrEn = 0;
    rdEn = 0;
    @(negedge clk);
    @(negedge clk);
    wrEn = 0;
    rdEn = 0;
    WrTask;      
    @(negedge clk);
    wrEn = 0;
    rdEn = 0;
    RdTask;      
    // simultaneously wr & rd vector
    @(negedge clk);
    wrEn = 0;
    rdEn = 0;
    @(negedge clk);
    @(negedge clk);
    wrEn = 0;
    rdEn = 0;
    WrTask;      
    @(negedge clk);
    wrEn = 0;
    rdEn = 0;
    RdTask; 
    WrTask;

    forever begin
      @(negedge clk);
      wrEn = 0;
      rdEn = 0;
      //WrTask;      
    end
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
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,TwoRegFifoTb,"+all");
    #30000;
    $finish();
  end

endmodule
