`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module pqindex_generetor#(parameter n=6,s0=4'd0,s1=4'd1,s2=4'd2,s3=4'd3,s4=4'd4)(
      input clk,
      input reset,
      input start_pq,
      output reg[2:0]p,
      output reg[2:0]q,
      output reg done_pq
    );

reg[3:0]state1;    
reg[10:0]count1,count2,count0,row_count;  //// maximum rows goes to 1024 of the output image matrix///////////
always@(posedge clk) begin
      if(reset)begin
          p<=1;count2<=1;
          q<=1;count1<=1;row_count<=1;
          count0<=1;done_pq<=0;
         
      end
      else  begin
      case(state1)
//////////////////////////////////////////////////////      
      s0:begin
         if(start_pq)begin
            p<=2;
            q<=0;
         end
         else begin
             p<=1;count2<=1;
             q<=1;count1<=1;row_count<=1;
             count0<=1;done_pq<=0;
         end    
      end
 //////////////////////////////////////////////////////     
      s1:begin
         if(count1==n)begin
           p<=1;
           q<=0;
           row_count<=row_count+1;
          
         end
         else begin
           count1<=count1+1;
           count2<=1;
           count0<=1;
         end
      end
 ///////////////////////////////////////////////////////     
       s2:begin
         if(count0==n)begin
           p<=0;
           q<=0;
           row_count<=row_count+1;
           
         end
         else begin
           count0<=count0+1;
           count2<=1;
           count1<=1;
         end
      end
 ///////////////////////////////////////////////////////
      s3:begin
         if(count2==n)begin
           p<=2;
           q<=0;
           row_count<=row_count+1;
          
         end
         else begin
           count2<=count2+1;
           count1<=1;
           count0<=1;
         end
      end     
      s4: begin
          done_pq<=1;
      end
      endcase
      end
      
      
end
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
always@(posedge clk) begin
      if(reset)begin
         state1<=s0;
      end
      
      else begin
        case(state1)
        s0:begin
          if(start_pq)begin
              state1<=s1;
          end
          else begin
              state1<=s0;
          end
       end
 ///////////////////////////////////////////////////////      
       s1:begin
          if(count1==n && count2==1 && count0==1)
             state1<=s2;
          else if(row_count==n-2)  
             state1=s4; 
          else
             state1<=s1;   
       end
       s2:begin
          if(count1==1 && count2==1 && count0==n)
             state1<=s3;
          else if(row_count==n-2)  
             state1<=s4;    
          else
             state1<=s2;   
       end
        s3:begin
          if(count1==1 && count2==n && count0==1)
             state1<=s1;
          else if(row_count==n-2)  
             state1<=s4;    
          else
             state1<=s3;   
 ///////////////////////////////////////////////////////            
       end
       s4:begin
          if(start_pq==0)begin
            state1<=s0;
          end
          else begin
            state1<=s4;
          end
       end
       endcase 
end
end
///////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule