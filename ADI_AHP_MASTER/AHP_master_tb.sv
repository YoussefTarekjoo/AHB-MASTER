import AHP_MASTER_PKG ::*;

module AHP_master_tb() ;

localparam 		    Add	           = 2'b00; // A + B
localparam 		    Sub	           = 2'b01; // A - B
localparam 		    Not_A	       = 2'b10; // ~A
localparam 		    ReductionOR_B  = 2'b11; // |B

logic HREADY  , HCLK , Enable_Transfer , HRESETn , HWRITE ;
logic [31:0] HADDR ;
logic signed [31:0] HRDATA , HWDATA , A_tb , B_tb , C_tb  ;
HTRANS_ENUM	 HTRANS ;
logic [2:0] HSIZE , HBURST ;
logic [63:0] CPU_OUT ;
logic [1:0] Opcode ;

integer error_count , correct_count ;

AHP_master AHP_master_DUT
(
 .HREADY(HREADY)                   ,
 .HCLK(HCLK)                       ,
 .Enable_Transfer(Enable_Transfer) ,
 .HRESETn(HRESETn)                 ,
 .HRDATA(HRDATA)                   ,  
 .CPU_OUT(CPU_OUT)                 ,
 .HADDR(HADDR)                     ,
 .HWRITE(HWRITE)                   ,
 .HSIZE(HSIZE)                     ,
 .HBURST(HBURST)                   ,
 .HTRANS(HTRANS)                   ,
 .HWDATA(HWDATA)  
);

always #1 HCLK = ~HCLK ;

initial 
 begin
  init ;
  assert_reset ;
  if(HTRANS == IDLE)
   begin
    $display("Test Case 1 passed Success <<Reset Case>>") ;
	correct_count = correct_count + 1 ;
   end
  
  CPU_OUT = 64'hAB02123400841578 ;
  Enable_Transfer = 1 ;
  HREADY = 1 ; 
  
  #2
  
  if(HTRANS == NON_SEQ)
   begin
    $display("Test Case 2 passed Success <<REQ for Transfer>>") ;
	correct_count = correct_count + 1 ;
   end
   
   #1
   HRDATA = 32'hABCDEF23 ;
   A_tb = HRDATA ;
   #1
   
  if(HTRANS == IDLE)
   begin
    $display("Test Case 3 passed Success <<Transfer Data Is Done Success and write in A_ALU REGISTER>>") ;
	correct_count = correct_count + 1 ;
   end
   
  CPU_OUT = 64'hAF6CD12340084156A ;
  Enable_Transfer = 1 ;
  HREADY = 1 ;
  
  #2
  
  if(HTRANS == NON_SEQ)
   begin
    $display("Test Case 4 passed Success <<REQ for Transfer>>") ;
	correct_count = correct_count + 1 ;
   end
   
   #1
   HRDATA = 32'h012356BC ;
   B_tb = HRDATA ;
   #1
   
  if(HTRANS == IDLE)
   begin
    $display("Test Case 5 passed Success <<Transfer Data Is Done Success and write in B_ALU REGISTER>>") ;
	correct_count = correct_count + 1 ;
   end
   
  CPU_OUT = 64'hA89512340084157B ;
  Enable_Transfer = 1 ;
  HREADY = 1 ;
  Opcode = CPU_OUT[63:62] ;
  golden_model_ALU(A_tb , B_tb , C_tb) ;
  #2
  
  if(HTRANS == NON_SEQ)
   begin
    $display("Test Case 6 passed Success <<In NON_SEQ  state>>") ;
	correct_count = correct_count + 1 ;
   end
   
   #2
   
  if(HTRANS == IDLE && HWDATA == C_tb)
   begin
    $display("Test Case 7 passed Success <<HWDATA = %0h , C_tb = %0h>>" , HWDATA , C_tb) ;
	correct_count = correct_count + 1 ;
   end
   
  CPU_OUT = 64'hAD4D12340F841576 ;
  Enable_Transfer = 1 ;
  HREADY = 1 ;
  
  #2

  #1
  HRDATA = 32'hAFD65498 ;
  A_tb = HRDATA ;
  #1
  CPU_OUT = 64'hABCD123401841574 ;
  HRDATA = 32'hCDAF9870 ;
  B_tb = HRDATA ;
  #2
  HRDATA = 32'hC1234870 ;
  #2
  HRDATA = 32'hCDAF9870 ;
  #2
  HRDATA = 32'h89AB452F ;
  
  if(HTRANS == SEQ)
   begin
    $display("Test Case 8 passed Success <<IN SEQ>>") ;
	correct_count = correct_count + 1 ;
   end
  
  #2
  
  CPU_OUT = 64'hA89512340084157B ;
  Enable_Transfer = 1 ;
  HREADY = 1 ;
  
  
  #2
  
  Enable_Transfer = 0 ;
  
  #2
  
  if(HTRANS == BUSY)
   begin
    $display("Test Case 9 passed Success <<IN BUSY>>") ;
	correct_count = correct_count + 1 ;
   end
  
  $display("error_count = %0d , correct_count = %0d", error_count , correct_count) ;
  $stop;
 end
 
task golden_model_ALU(input signed [31:0] A , input signed [31:0] B , output signed [31:0] C_tb) ;
 case (Opcode)
    Add:            C_tb = A + B;
    Sub:            C_tb = A - B;
    Not_A:          C_tb = ~A;
    ReductionOR_B:  C_tb = |B;
 endcase
endtask
 
task init ;
 A_tb = 0 ;
 B_tb = 0 ;
 Opcode = 0 ;
 C_tb = 0 ;
 error_count = 0 ;
 Enable_Transfer = 0 ;
 correct_count = 0 ;
 HREADY = 0 ;
 CPU_OUT = 0 ;
 HCLK = 0 ;
endtask

task assert_reset ;
 HRESETn = 0 ;
 #2
 HRESETn = 1 ;
endtask

endmodule