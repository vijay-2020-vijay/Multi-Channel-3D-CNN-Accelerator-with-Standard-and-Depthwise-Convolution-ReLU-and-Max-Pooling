`timescale 1ns / 1ps  
module mac9 (
    input clk,
    input reset,

    input signed [31:0] I0, I1, I2, I3, I4, I5, I6, I7, I8,
    input signed [31:0] W0, W1, W2, W3, W4, W5, W6, W7, W8,
    output reg signed [31:0]out_con
 
);

    // Stage 1: Multiplication
    reg signed [31:0] P0, P1, P2, P3, P4, P5, P6, P7, P8;
    reg signed[31:0]a,b,c,d,e,f,g,h,i,i1;
    wire signed[31:0]sum1,sum2;
    reg signed[31:0]sum;
    adder add1(.a(a),.b(b),.c(c),.d(d),.sum1(sum1));
    adder add2(.a(e),.b(f),.c(g),.d(h),.sum1(sum2));
    
///////////////stage1///////////////////////////////////////////
    always @(posedge clk) begin
        if (reset) begin
            P0 <= 0; P1 <= 0; P2 <= 0; P3 <= 0; P4 <= 0;
            P5 <= 0; P6 <= 0; P7 <= 0; P8 <= 0;
        end else begin
            P0 <= I0 * W0;
            P1 <= I1 * W1;
            P2 <= I2 * W2;
            P3 <= I3 * W3;
            P4 <= I4 * W4;
            P5 <= I5 * W5;
            P6 <= I6 * W6;
            P7 <= I7 * W7;
            P8 <= I8 * W8;
        end
    end
///////////Stage 2: Group-wise addition and tree reduction/////////
    always @(posedge clk) begin
        if (reset) begin
            a<=0; b<=0;c<=0; d<=0;
            e<=0; f<=0;g<=0; h<=0;
            end
        else begin
             a<=P0;b<=P1;c<=P2;
             d<=P3;e<=P4;f<=P5;
             g<=P6;h<=P7;i<=P8;
        end
    end
/////////////Stage 3: ReLU Activation/////////////////////////////////
 always @(posedge clk) begin
        if (reset) begin
            sum <= 0;
          
        end    
        else
           sum<=sum1+sum2;
           i1<=i;
           
    end

//////////////////////////////////////////////////////////////////
/////////////Stage 4: ReLU Activation/////////////////////////////////
   always @(posedge clk) begin
        if (reset) begin
            //out <= 0;
        end    
        else
            out_con<=sum+i1;
           // out <= (sum+i1<= 0) ? 32'd0 : sum+i1;
    end
endmodule
//////////////////////////////////////////////////////////////////

module adder (
    input [31:0] a, b, c, d,
    output signed[31:0] sum1
);
    // Layer 1: 4 pairs + 1 leftover
    wire signed[31:0] s0 = a + b;
    wire signed[31:0] s1 = c + d;
    assign  sum1 = s0 + s1;
endmodule
///////////////////////////////////////////////////////////////////