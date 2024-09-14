package AHP_MASTER_PKG ;
 
 typedef enum logic [1:0] {
        IDLE                 = 2'b00 , 
        BUSY                 = 2'b01 ,
        NON_SEQ              = 2'b10 ,
        SEQ                  = 2'b11 
    } HTRANS_ENUM ;

endpackage