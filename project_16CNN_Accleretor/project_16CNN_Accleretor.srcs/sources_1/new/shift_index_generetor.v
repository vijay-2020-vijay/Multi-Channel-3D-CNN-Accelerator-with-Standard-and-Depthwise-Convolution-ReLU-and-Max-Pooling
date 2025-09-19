`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/////here n is the number of rows of image matrix////////////////////////////////
module shift_index_generetor#(parameter n=6,s0=3'd0,s1=3'd1,s2=3'd2,s3=3'd3)(
       input clk,
       input reset,
       input[2:0] ina,
       input[2:0] inb,
       output reg complete20,complete10,complete00,
       output reg [2:0]p0,p1,p2,p3,p4,p5,p6,p7,p8,  ///pi always decides number of rows which is fixed (i.s 3)///////////////////
       output reg [10:0]q0,q1,q2,q3,q4,q5,q6,q7,q8 ////qi always decides the number of collums which maximum value goes to 1024//
 );
 reg[4:0]state4;
 reg[10:0]count20,count10,count00;  ///10 is enough  means maximaum number of collum is 1024///
 /////////////////////////////////////////////////////////////////////////////////////////////
 always@(posedge clk)begin
          if(reset)begin
             complete00<=0;complete10<=0;
             complete20<=0;count20<=0;
             count10<=0;count00<=0;
            
          end
          else begin
 /////////////////////////////////////////////////////////////
          case(state4)
          s0:begin
            p0 <= 0;   p1 <= 0;  p2 <= 0;
            p3 <= 0;   p4 <= 0;  p5 <= 0;
            p6 <= 0;   p7 <= 0;  p8 <= 0;

           q0 <= 0;   q1 <= 0;  q2 <= 0;
           q3 <= 0;   q4 <= 0;  q5 <= 0;
           q6 <= 0;   q7 <= 0;  q8 <= 0;
           count10<=0;count00<=0;count20<=0; 
            
            
          end
 //////////////////////////////////////////////////////////////////         
          s1:begin
              p0<=2;   p1<=2;  p2<=2;
              p3<=1;   p4<=1;  p5<=1;
              p6<=0;   p7<=0;  p8<=0;
          
             q0<=count20 ;   q1<=count20+1 ;   q2<=count20+2 ;
             q3<=count20 ;   q4<=count20+1 ;   q5<=count20+2 ;
             q6<=count20 ;   q7<=count20+1 ;   q8<=count20+2 ;
             count20<=count20+1;
             if(count20==n-4)begin//// order of output image matrix  n-2*n-2  here karnel is fixed(3*3)
                complete20<=1;
                complete10<=0;
                complete00<=0;
     
            end
            end
////////////////////////////////////////////////////////////////////            
            s2:begin
             p0<=1;   p1<=1;   p2<=1;
             p3<=0;   p4<=0;   p5<=0;
             p6<=2;   p7<=2;   p8<=2;
      
            
             q0<=count10 ;   q1<=count10+1 ;   q2<=count10+2 ;
             q3<=count10 ;   q4<=count10+1 ;   q5<=count10+2 ;
             q6<=count10 ;   q7<=count10+1 ;   q8<=count10+2 ;
             count10<=count10+1;
             if(count10==n-4)begin//// order of output image matrix  n-2*n-2  here karnel is fixed(3*3)
                complete20<=0;
                complete10<=1;
                complete00<=0;

            end
            end 
 ///////////////////////////////////////////////////////////////////           
            s3:begin
             p0<=0;  p1<=0;  p2<=0;
             p3<=2;  p4<=2;  p5<=2;
             p6<=1;  p7<=1;  p8<=1;
            
             q0<=count00 ;   q1<=count00+1 ;   q2<=count00+2 ;
             q3<=count00 ;   q4<=count00+1 ;   q5<=count00+2 ;
             q6<=count00 ;   q7<=count00+1 ;   q8<=count00+2 ;
             count00<=count00+1;
             if(count00==n-4)begin//// order of output image matrix  n-2*n-2  here karnel is fixed(3*3)
                complete20<=0;
                complete10<=0;
                complete00<=1;
   
             end
            end 
          endcase
            end      
 end
 //////////////////////////////////////////////////////////////////////////////////////////
 ////////////state4 _decission/////////////////////////////////////////////////////////////
 ////////////////////////////////////////////////////////////////////////////////////////
always@(posedge clk)begin
       if(reset)begin
          state4<=s0;
       end
       else begin
        case(state4)
        s0:begin
           if(ina==2 && inb==0 && complete20==0 )begin
               state4<=s1;
           end
           else if(ina==1 && inb==0 && complete10==0 )begin
              state4<=s2;
           end
           else if(ina==0 && inb==0 && complete00==0 )begin
              state4<=s3;  
           end
           else if(ina==1 && inb==1) begin
              complete20<=0;complete10<=0;complete00<=0;
              state4<=s0;
           end
        end
 ///////////////////////////////////////////////////////////////////////////////////////////       
       s1:begin
          if(complete20==1 && complete10==0 && complete00==0)begin
              state4<=s0;
          end
          else begin
              state4<=s1;
          end
       end
////////////////////////////////////////////////////////////////////////////////////////       
       s2:begin
          if(complete20==0 && complete10==1 && complete00==0)begin
               state4<=s0;
          end
          else begin
               state4<=s2;
          end
       end
////////////////////////////////////////////////////////////////////////////////////////       
       s3:begin
          if(complete20==0 && complete10==0 && complete00==1)begin
               state4<=s0;
          end
          else begin
               state4<=s3;
          end
       end       
        default:begin
              state4<=s0;  
        end
       endcase
 end
 end
 ///////////////////////////////////////////////////////////////////////////////////////
 //////////////end  end////////////////////////////////////////////////////////////////
 //////////////////////////////////////////////////////////////////////////////////////
endmodule
