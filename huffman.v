module huffman(clk, reset, gray_valid, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
    code_valid, HC1, HC2, HC3, HC4, HC5, HC6);

input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output CNT_valid;
output [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output code_valid;
output [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output [7:0] M1, M2, M3, M4, M5, M6;

//------------------------------------------------------------------
// reg & wire
reg [3:0] state, state_next;
parameter IDLE = 3'b0000;

parameter CNT2C0 = 3'b0100;
parameter SORT = 3'b0101;
parameter SORT_CHECK = 3'b0110;
parameter COMBINATION = 3'b0111;

reg [7:0] CNT1_buf, CNT2_buf, CNT3_buf, CNT4_buf, CNT5_buf, CNT6_buf;
wire [7:0] CNT1_next, CNT2_next, CNT3_next, CNT4_next, CNT5_next, CNT6_next;
assign CNT1_next = CNT1;
assign CNT2_next = CNT2;
assign CNT3_next = CNT3;
assign CNT4_next = CNT4;
assign CNT5_next = CNT5;
assign CNT6_next = CNT6;
reg [6:0] C0 [0:5];
reg [6:0] C1 [0:4];
reg [6:0] C2 [0:3];
reg [6:0] C3 [0:2];
reg [6:0] C4 [0:1];
reg [6:0] C0_next [0:5];
reg [6:0] C1_next [0:4];
reg [6:0] C2_next [0:3];
reg [6:0] C3_next [0:2];
reg [6:0] C4_next [0:1];
reg [2:0] sort_count, sort_count_next;
reg [2:0] sort_change, sort_change_next;
reg [5:0] symbol0 [0:5];
reg [5:0] symbol1 [0:4];
reg [5:0] symbol2 [0:3];
reg [5:0] symbol3 [0:2];
reg [5:0] symbol4 [0:1];
reg [5:0] symbol0_next [0:5];
reg [5:0] symbol1_next [0:4];
reg [5:0] symbol2_next [0:3];
reg [5:0] symbol3_next [0:2];
reg [5:0] symbol4_next [0:1];

reg [6:0] C_sort [0:5];
reg [6:0] C_sort_next [0:5];
reg [5:0] symbol_sort [0:5];
reg [5:0] symbol_sort_next [0:5];
reg [2:0] do, do_next;
//------------------------------------------------------------------
// combinational part
always@(*) begin
    case(state)
        IDLE:begin
            sort_count_next = 0;
            sort_change_next = 0;
            do_next = 5;
        end
        CNT2C0:begin
            C_sort_next[0] = CNT1_buf;
            C_sort_next[1] = CNT2_buf;
            C_sort_next[2] = CNT3_buf;
            C_sort_next[3] = CNT4_buf;
            C_sort_next[4] = CNT5_buf;
            C_sort_next[5] = CNT6_buf;
            symbol_sort_next[0] = 6'b000001;
            symbol_sort_next[1] = 6'b000010;
            symbol_sort_next[2] = 6'b000100;
            symbol_sort_next[3] = 6'b001000;
            symbol_sort_next[4] = 6'b010000;
            symbol_sort_next[5] = 6'b100000;
            state_next = SORT;
            do_next = 5;
        end
        SORT:begin
            if C_sort[sort_count + 1] > C_sort[sort_count]begin
                C_sort_next[sort_count] = C_sort[sort_count + 1];
                C_sort_next[sort_count + 1] = C_sort[sort_count];
                symbol_sort_next[sort_count] = symbol_sort[sort_count + 1];
                symbol_sort_next[sort_count + 1] = symbol_sort[sort_count];
                sort_change_next = sort_change + 1;
            end

            if(sort_count == do - 1)begin 
                // only check the previous (do) ex: C0 check previous 5, C1 check previous 4, ...
                sort_count_next = 0;
                state_next = SORT_CHECK;
            end
            else begin
                sort_count_next = sort_count + 1;
                state_next = SORT;
            end
            
        end
        SORT_CHECK:begin
            if(sort_change == 0)begin
                state_next = COMBINATION;
                if(do == 5)begin//do = 5 means C0 is sorted
                    for(i=0;i<=do;i=i+1)begin 
                        C0_next[i] = C_sort[i];
                        symbol0_next[i] = symbol_sort[i];
                    end
                end
                if(do == 4)begin//do = 4 means C1 is sorted
                    for(i=0;i<=do;i=i+1)begin 
                        C1_next[i] = C_sort[i];
                        symbol1_next[i] = symbol_sort[i];
                    end
                end
                if(do == 3)begin//do = 3 means C2 is sorted
                    for(i=0;i<=do;i=i+1)begin 
                        C2_next[i] = C_sort[i];
                        symbol2_next[i] = symbol_sort[i];
                    end
                end
                if(do == 2)begin//do = 2 means C3 is sorted
                    for(i=0;i<=do;i=i+1)begin 
                        C3_next[i] = C_sort[i];
                        symbol3_next[i] = symbol_sort[i];
                    end
                end
                if(do == 1)begin//do = 1 means C4 is sorted
                    for(i=0;i<=do;i=i+1)begin 
                        C4_next[i] = C_sort[i];
                        symbol4_next[i] = symbol_sort[i];
                    end
                end
            end
            else begin
                state_next = SORT;
                sort_change_next = 0;
            end
        end
        COMBINATION:begin
            //C0 is a sorted probability table labeled by symbol0
            if(do = 5)begin//do = 5 means C0 is sorted
                C_sort_next[0] = C0[0];
                C_sort_next[1] = C0[1];
                C_sort_next[2] = C0[2];
                C_sort_next[3] = C0[3];
                C_sort_next[4] = C0[4] + C0[5];
                symbol_sort[0] = symbol0[0];
                symbol_sort[1] = symbol0[1];
                symbol_sort[2] = symbol0[2];
                symbol_sort[3] = symbol0[3];
                symbol_sort[4] = symbol0[4] + symbol0[5];
                do_next = 4;//do = 4 means C1 is going to be sorted
            end
            if(do = 4)begin//do = 4 means C1 is sorted
                C_sort_next[0] = C1[0];
                C_sort_next[1] = C1[1];
                C_sort_next[2] = C1[2];
                C_sort_next[3] = C1[3] + C1[4];
                symbol_sort[0] = symbol1[0];
                symbol_sort[1] = symbol1[1];
                symbol_sort[2] = symbol1[2];
                symbol_sort[3] = symbol1[3] + symbol1[4];
                do_next = 3;//do = 3 means C2 is going to be sorted
            end
            if(do = 3)begin//do = 3 means C2 is sorted
                C1[0] = C0[0];
                C1[1] = C0[1];
                C1[2] = C0[2];
                C1[3] = C0[3];
                C1[4] = C0[3] + C0[4];
                do_next = 2;//do = 2 means C3 is going to be sorted
            end
            if(do = 2)begin//do = 2 means C3 is sorted
                C1[0] = C0[0];
                C1[1] = C0[1];
                C1[2] = C0[2];
                C1[3] = C0[3];
                C1[4] = C0[3] + C0[4];
                do_next = 1;//do = 1 means C4 is going to be sorted
            end
            if(do == 1)begin
                
            end
            

        end
    endcase
end

//------------------------------------------------------------------
// sequential part
always@( posedge clk or posedge reset) begin
    if(reset==1'b1) begin
    
    end
    else begin
        CNT1_buf <= CNT1_next;
        CNT2_buf <= CNT2_next;
        CNT3_buf <= CNT3_next;
        CNT4_buf <= CNT4_next;
        CNT5_buf <= CNT5_next;
        CNT6_buf <= CNT6_next;
        for(i = 0;i <= 5;i=i+1)begin
            C0[i] = C0_next[i];
            C1[i] = C1_next[i];
            C2[i] = C2_next[i];
            C3[i] = C3_next[i];
            C4[i] = C4_next[i];
        end
        sort_count <= sort_count_next;
        sort_change <= sort_change_next;

    end
end
    
endmodule

