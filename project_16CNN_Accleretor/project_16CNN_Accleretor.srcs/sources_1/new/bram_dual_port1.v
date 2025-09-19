`timescale 1ns / 1ps   

module bram_dual_port1 #( MA=18, DEPTH =2**MA)(
    input wire clk,
    input startb,
    input max_pool_store,
    input con_add,////////////////////////////////////////after i channel we need to sent k=1;at first k=0;
    // Port A (Read side: kernels & image pixels)
    input wire [MA-1:0] addr_a,
    input wire we_a,
    input wire signed [31:0] din_a,
    output reg signed [31:0] dout_a,
 //////////////////////////////////////////////////////////////////////////////////////////////   
    input wire [MA-1:0] addr_b,
    input wire signed [31:0] din_b, 
    output reg signed [31:0] dout_b
);
   (* ram_style = "block" *) reg signed[31:0] mem [0:DEPTH-1];
    initial $readmemh("D:/memorey test file for cnn_accleretor/pixels_channelwise_amp_hex.txt", mem);
   reg signed [31:0]temp1,temp2;
////////Port A/////////portA///////////////read is always happend 
/////when we_a=1//then only write possible//////////////////////
always @(posedge clk) begin
    if (we_a)
        mem[addr_a] <= din_a;   // write happens  
     dout_a <= mem[addr_a];      // read always happens
end
//////////portB/////////portB/////////////////////////////////////////////////////////////////////
///its behaviour is quite different when startb=1 then only portb is active///////////////////////
////this is two stage pipelned system it reads the and writes then accumultae both then store///// 
    always @(posedge clk) begin
        if(startb)begin
          temp1<=con_add?mem[addr_b]:0;
          temp2<=din_b;
          
        end
        else begin
          temp1<=0;
          temp2<=0;
        end
        
    end    
    always @(posedge clk) begin
        if(startb)begin
          mem[addr_b]<= temp1+ temp2;
          dout_b<=temp1+ temp2;
        end
         else begin
          temp1<=0;
          temp2<=0;
        end
        
        
        
    end 
    
    always@(posedge clk) begin
     if(max_pool_store)
         mem[addr_b]<=din_b;         
    end
    
endmodule