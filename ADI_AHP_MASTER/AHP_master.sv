import AHP_MASTER_PKG ::*;

module AHP_master 
(
 input wire HREADY                     ,
 input wire HCLK                       ,
 input wire Enable_Transfer            ,
 input wire HRESETn                    ,
 input wire signed [31:0] HRDATA       ,
 input wire [63:0] CPU_OUT             ,
 output reg [31:0] HADDR               ,
 output reg HWRITE                     ,
 output reg [2:0] HSIZE                ,
 output reg [2:0] HBURST               ,
 output HTRANS_ENUM HTRANS             ,
 output reg signed [31:0] HWDATA   
);

reg signed [31:0] A ;
reg signed [31:0] B ;
wire signed [31:0] ALU_OUT ;

ALU_31_bit ALU(
  .Opcode(CPU_OUT[63:62]) ,
  .A(A) ,
  .B(B) ,
  .C(ALU_OUT) 
 );

reg [31:0] HADDR_SAVE      ;
reg [2:0] COUNTER ;

always @(posedge HCLK or negedge HRESETn)
 begin
  if(!HRESETn)
   begin
    HADDR <= 0 ;
	HWRITE <= 0 ;
	HSIZE <= 0 ;
	HBURST <= 0 ;
	COUNTER <= 0 ;
	HWDATA <= 0 ;
	HTRANS <= IDLE ;
   end
  else
   begin
    case(HTRANS)
	IDLE : begin
	 if(Enable_Transfer && HREADY)
	    begin
	     COUNTER <= 0 ;
	     HTRANS <= NON_SEQ ;
	     HADDR <= CPU_OUT[63:32] ;
	     HWRITE <= CPU_OUT[0] ;
	     HSIZE <= CPU_OUT[31:29] ;
	     HBURST <= CPU_OUT[28:26] ;
		end
	 else
	  begin
	   HTRANS <= IDLE ;
	  end
	end
	
	NON_SEQ : begin
	 if(HREADY && Enable_Transfer)
	  begin
	  if(HWRITE)
	   HWDATA <= ALU_OUT ;
	  else
	   begin
	   if(CPU_OUT[4])
	    A <= HRDATA ;
	   else
	    B <= HRDATA ;
	   end
	   if(HBURST)
	    begin
		 HADDR <= HADDR + (1 << HSIZE) ;
		 COUNTER <= COUNTER + 1 ;
         HTRANS <= SEQ ;
		end
	   else
	    begin
		 HTRANS <= IDLE ;
		end
	  end
	 
	 else if(!Enable_Transfer)
	  begin
	   HTRANS <= BUSY ;
	  end
	 
	 else
	  begin
	   HTRANS <= NON_SEQ ;
	  end
	 
	end
	
	SEQ : begin
	 if(HREADY && Enable_Transfer)
	  begin
	   if(HWRITE)
	    HWDATA <= ALU_OUT ;
	   else
	    begin
	    if(CPU_OUT[1])
	     A <= HRDATA ;
	    else
	     B <= HRDATA ;
	    end
		 COUNTER <= COUNTER + 1 ;
		 if(COUNTER < CPU_OUT[3:0])
		  begin
           HTRANS <= SEQ ;
		   HADDR <= HADDR + (1 << HSIZE) ;
		  end
		 else
		  begin
		   HTRANS <= IDLE ;
		   COUNTER <= 0 ;
		  end
	    end	
	 else if(!Enable_Transfer)
	  begin
	   HTRANS <= BUSY ;
	  end
	 else begin
	   HTRANS <= SEQ ;
	  end
	end
	
	BUSY:begin
	 if(Enable_Transfer)
	  begin
	   HTRANS <= SEQ ;
	  end
	 else
	  begin
	   HTRANS <= BUSY ;
	  end
	end
  endcase
   end
 end

endmodule
