`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
module max_pool4 (
    input clk,
    input reset,
    input  signed [31:0] a,
    input  signed [31:0] b,
    input  signed [31:0] c,
    input  signed [31:0] d,
    output wire signed [31:0] max_out,
    output reg complete_max
);
////////////////////////////////////////////////////////////////////////////////////
reg signed[31:0]a1,b1,c1,d1,e1,f1;
wire signed[31:0]max_out1,max_out2;
maxi2 m1(.a(a1),.b(b1),.max_out(max_out1));
maxi2 m2(.a(c1),.b(d1),.max_out(max_out2));
maxi2 m3(.a(e1),.b(f1),.max_out(max_out));
///////////////////////////////////////////////////////////////////////////////////
always@(posedge clk) begin
       if(reset)begin
          complete_max<=0;
       end
       else begin
         a1<=a;b1<=b;
         c1<=c;d1<=d;
       end
 end      
 always@(posedge clk) begin
       if(reset)begin
          complete_max<=0;
       end
       else begin
         e1<=max_out1;
         f1<=max_out2;
         
         complete_max<=1;
       end
 end     
 /////////////////////////////////////////////////////////////////////////////
endmodule
///////////////////////////////////////////////////////////////////////////////
module maxi2 (
    input  signed [31:0] a,
    input  signed [31:0] b,
    output signed [31:0] max_out
);

    assign max_out = (a >= b)  ? a : b;
    

endmodule
/////////////////////////////////////////////////////////////////////////////