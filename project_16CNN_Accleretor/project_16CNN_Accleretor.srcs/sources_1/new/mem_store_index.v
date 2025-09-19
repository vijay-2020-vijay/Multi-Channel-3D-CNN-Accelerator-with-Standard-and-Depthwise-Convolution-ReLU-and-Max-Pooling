`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//here n actually size of the matrix
module mem_store_index #(parameter n=6,MA=15,s0=3'd0,s1=3'd1,s2=3'd2,s3=3'd3,s4=3'd4,s5=3'd5)(
      input clk,
      input reset,
      input start_mem_store,
      output reg[MA-1:0]mem_store_address,///maximam memorey address is 2**15=32,728//we will use it seperate memorey//
      output reg mem_store_done
    );
 /////here karnel size is fixed(3*3) ///stride=1//pooling matrix is also fixed(2*2)// 
////size of the polling matrix should be n-3 * n-3///////////////////////////////// 
 reg[2:0]state3;
 reg[10:0]countk;/////this count value actually tress the row of the max pooled matrix////(1024 value is sufficient)
 reg[10:0]countkk;
 always@(posedge clk)begin
        if(reset)begin
           countk<=0;
           countkk<=0;
           mem_store_done<=0;
           mem_store_address<=0;
           state3<=s0;
        end
        else begin
          case(state3)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////         
          s0:begin
             if(start_mem_store)begin
                countk<=1;
                mem_store_address<=1;
                state3<=s1;
             end
          end
         s1:begin
            if(countk==n-3)begin
               countkk<=countkk+1;
               state3<=s2;
            end
            else begin
               mem_store_address<= mem_store_address+1;
               countk<=countk+1;
            end
         end 
         
         s2:begin
            countk<=0;
            state3<=s3;
            if(countkk==n-3)begin
               state3<=s5;
            end
         end
         s3:begin
             state3<=s1;
         end
         s5:begin
            mem_store_done<=1;
            if(start_mem_store==0)begin
               countk<=0;
               countkk<=0;
               mem_store_done<=0;
               mem_store_address<=0;
               state3<=s0;
               end
            else begin
              state3<=s5;
            end  
         end
         endcase
        end
 end
endmodule