module ALU_31_bit (
    input  [1:0] Opcode,	// The opcode
    input  signed [31:0] A,	// Input data A in 2's complement
    input  signed [31:0] B,	// Input data B in 2's complement

    output reg signed [31:0] C // ALU output in 2's complement

		  );

   localparam 		    Add	           = 2'b00; // A + B
   localparam 		    Sub	           = 2'b01; // A - B
   localparam 		    Not_A	         = 2'b10; // ~A
   localparam 		    ReductionOR_B  = 2'b11; // |B

   // Do the operation
   always @* begin
      case (Opcode)
      	Add:            C = A + B;
      	Sub:            C = A - B;
      	Not_A:          C = ~A;
      	ReductionOR_B:  C = |B;
        default:  C = 5'b0;
      endcase
   end 

endmodule