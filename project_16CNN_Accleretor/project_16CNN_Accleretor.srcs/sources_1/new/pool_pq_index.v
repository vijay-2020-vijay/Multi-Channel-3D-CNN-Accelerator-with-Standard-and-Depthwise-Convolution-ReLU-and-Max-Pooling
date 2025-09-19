`timescale 1ns / 1ps   
//////////////////////////////////////////////////////////////////////////////////
module pool_pq_index#(parameter n=6,s0=2'd0,s1=2'd1,s2=2'd2,s3=3'd3,s4=3'd4)(
         input clk,
         input reset,
         input start_pool,
         output reg[2:0]a0,a1,a2,a3,
         output reg[10:0]b0,b1,b2,b3,///nomber of collumn is sufficient
         output reg pool_row,
         output reg max_pool_complete   
    );

reg[2:0]state2;    
reg[10:0]count_ab;///nomber of collumn is sufficient
reg[10:0]count_row;
always@(posedge clk) begin
        if(reset)begin
           pool_row<=0;
           count_ab<=0;
        end
        else begin
        case(state2)
        s0: begin
            a0<=0;a1<=0;a2<=0;a3<=0;
            b0<=0;b1<=0;b2<=0;b3<=0;
            count_ab<=0;pool_row<=0;
            count_row<=0;max_pool_complete<=0; 
        end
        s1:begin
            a0<=0;a1<=0;
            a2<=1;a3<=1;
            b0<=count_ab;b1<=count_ab+1;
            b2<=count_ab;b3<=count_ab+1;
            if(count_ab==n-4)begin
               count_row<=count_row+1;
               pool_row<=1;
            end
            else begin
              count_ab<=count_ab+1;
              pool_row<=0;
             end
         end   
        s2:begin
           count_ab<=0;
        end 
        s3:begin
           count_ab<=0;
        end  
        s4:begin
          max_pool_complete<=1;
        end        
        endcase
        end
end
///////////////////////////////////////////////////////////////////////
/////////state2 decleration////////////////////////////////////////////
always@(posedge clk)begin
      if(reset) begin
          state2<=s0;
      end
      
      else begin
        case(state2)
        s0:begin
          if(start_pool) begin
             state2<=s1;
          end
          else 
            state2<=s0;
        end 
       s1: begin
           if(count_row==n-3)begin
             state2<=s4;
           end
           else if(count_ab==n-4)
            state2<=s2; 
           else
            state2<=s1; 
        end  
      
      s2:begin
         if(count_ab==0)begin
            state2<=s3;
         end
         else
           state2<=s2;    
      end 
      s3:begin
         if(count_ab==0)begin
            state2<=s1;
         end
        else begin
            state2<=s3;
        end   
      end
      s4:begin
         if(start_pool==0) begin
            state2<=s0;
         end
         else begin
           state2<=s4;
         end
         
      end
      endcase
end
end
endmodule

