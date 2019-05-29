
module TwoRegFifo
#(WIDTH = "_"
)(
  input                            clk,rst,
  input                            iWrEn,
  input [WIDTH-1:0]                iWrDat,
  input                            iRdEn,
  output logic                     oFul,
  output logic                     oNotEmpty,
  output logic [$bits(iWrDat)-1:0] oRdDat
);

  logic [1:0][$bits(iWrDat)-1:0] datReg; 

  always_ff@(posedge clk) begin
    if(!rst) begin
      datReg[0]  <= '0;
      oFul       <= '0;
    end else if(oFul & iRdEn) begin
      datReg[0]  <= '0;
      oFul       <= '0;
    end else if(oNotEmpty & iWrEn & !oFul & !iRdEn) begin
      datReg[0]  <= iWrDat;
      oFul       <= '1;    
    end
  end

  always_ff@(posedge clk) begin
    if(!rst) begin
      datReg[1]  <= '0;
      oNotEmpty  <= '0;
    end else if(!oFul & iRdEn & !iWrEn) begin
      datReg[1]  <= '0;
      oNotEmpty  <= '0;
    end else if(((!oFul & iRdEn) | !oNotEmpty) & iWrEn) begin
      datReg[1]  <= iWrDat;
      oNotEmpty  <= '1;
    end else if(oFul & iRdEn) begin
      datReg[1]  <= datReg[0];
      oNotEmpty  <= '1;
    end
  end

  assign oRdDat = datReg[1];

endmodule: TwoRegFifo
