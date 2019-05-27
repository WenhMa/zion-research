
module TwoRegFifo
#(WIDTH = "_"
)(
  input                            clk,rst,
  input                            iWrEn,
  input [WIDTH-1:0]                iWrDat,
  input                            iRdEn,
  output logic                     oFul,
  output logic                     oEmpty,
  output logic [1:0]               oDatVld,
  output logic [$bits(iWrDat)-1:0] oRdDat
);

  logic [1:0][$bits(iWrDat)-1:0] datReg; 

  always_ff@(posedge clk) begin
    if(!rst) begin
      datReg[0]  <= '0;
      oDatVld[0] <= '0;
      oFul       <= '0;
    end else if(oFul & iRdEn) begin
      datReg[0]  <= '0;
      oDatVld[0] <= '0;
      oFul       <= '0;
    end else if(!oEmpty & iWrEn & !oFul & !iRdEn) begin
      datReg[0]  <= iWrDat;
      oDatVld[0] <= '1;
      oFul       <= '1;    
    end
  end

  always_ff@(posedge clk) begin
    if(!rst) begin
      datReg[1]  <= '0;
      oDatVld[1] <= '0;
      
      oEmpty     <= '1;
    end else if(!oFul & iRdEn & !iWrEn) begin
      datReg[1]  <= '0;
      oDatVld[1] <= '0;
      oEmpty     <= '1;
    end else if(((!oFul & iRdEn) | oEmpty) & iWrEn) begin
      datReg[1]  <= iWrDat;
      oDatVld[1] <= '1;
      oEmpty     <= '0;
    end else if(oFul & iRdEn) begin
      datReg[1]  <= datReg[0];
      oDatVld[1] <= '1;
      oEmpty     <= '0;
    end
  end

  assign oRdDat = datReg[1];

endmodule: TwoRegFifo
