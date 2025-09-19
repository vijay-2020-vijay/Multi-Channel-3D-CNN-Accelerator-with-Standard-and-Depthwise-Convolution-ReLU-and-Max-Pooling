
`timescale 1ns / 1ps 
     
////////////////////////////////////////////////////////////////////////////////////
///////image matrix should be square matrix(n*n)//n could be anything///////////////
//////karnel matrix should be squre matrix of (k*k)//k should also be anything /////
module CNN_Accleretor #(parameter n=256,n_t=n*n,k=3,ch=4,fi=4,MA=18,DEPTH = 2**MA,s0 = 4'd0,s1 = 4'd1,s2 = 4'd2,s3=4'd3,s4=4'd4,s5=4'd5,s6=4'd6,s7=4'd7)(
               input clk,
               input reset,
               input[MA-1:0]kbase_address,
               input[MA-1:0]ibase_address,
               input[MA-1:0]maxpoo1_store_address,
              // input [MA-1:0]Bmem_read_addr,/////this is used actually read the data from mem////////////
               output reg karnel_complete,
               output reg image_row_complete,
               output reg con_rellu_complete,
               output reg image_row_pool_complete
              // output wire[31:0]Bmem_read_data/////this is used actually read the data from mem////////////
               );
//////////////////////////////////////////////////////////////////////////////////////////////////////////
reg signed[31:0]line[0:k-1][0:n-1];
//reg signed[31:0]line_pool[0:k-2][0:n-1];
(* ram_style = "block" *)reg signed[31:0]karnel_matrix[0:k*k-1];////later on we have to handle this things to the mac unit very careful//////////////////////
reg [MA-1:0]kkbase_address;
reg [MA-1:0]iibase_address;
reg[MA-1:0]maxpoo1_store_address_v;
reg[6:0]chh_no;/////////////////maximum we set it 64 which is more than sufficient/////////////////////////
reg  ch_convolution;//this signal will be used for conformetion of finished multichannel convolution///////
reg[6:0]fi_no;/////////////////maximum we set it 64 which is more than sufficient/////////////////////////
reg multi_ch_multi_fil_complete;
//////////////////////////////////////////////////////////////////////////////////////////////////////////
reg [3:0] state;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg[5:0]ik;//////////////////////set it fixed //used to count the karnel element///////////////////////////////////////////////////////
reg[k-1:0]ir,irr; /////////////////remmember number of rows will be decided by order of karnel matrix////////////////////////////////////
reg[15:0]ic,icc;/////////////////number of column will also be decided by order of image matrix/////////////////////////////////////////
reg[MA-1:0]icount,iicount;/////2**15  is too much sufficient  

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////instantiation of BRAM//////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg start_mem_store;
wire[MA-1:0]mem_store_address;
wire signed[31:0]max_out;
/////////////////////////////////////////////////////////
wire signed[31:0] dout_a, dout_b;
reg [MA-1:0]portA_address;
reg [MA-1:0]portB_address;
reg [MA-1:0]portBB_address;
reg max_pool_store;
reg we_a;
reg signed[31:0]din_a;
reg signed[31:0]din_b;
reg startb,con_add;
(* keep_hierarchy = "yes" *)bram_dual_port1 #(.MA(MA)) bram_inst (
    .clk(clk),
    .startb(startb),
    .con_add(con_add),
    // Port A: for reads
    .addr_a(portA_address),// or ibase_address+icount depending on state//kbase_address + ik
    .we_a(we_a),                // only reading
    .din_a(din_a),
    .dout_a(dout_a),
    // Port B: for writes (pooled result)
    .addr_b(portB_address),
    .din_b(din_b),
    .dout_b(dout_b),
    .max_pool_store(max_pool_store)
);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////instantiation of shift_index_generetor//////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire[2:0]p0,p1,p2,p3,p4,p5,p6,p7,p8;
wire[10:0]q0,q1,q2,q3,q4,q5,q6,q7,q8;
wire complete20,complete10,complete00;
reg[2:0]ina,inb;
 (* keep_hierarchy = "yes" *)shift_index_generetor#(.n(n)) sig(
        .clk(clk),.reset(reset),.ina(ina),.inb(inb),
        .complete20(complete20),.complete10(complete10),.complete00(complete00),
        .p0(p0),.p1(p1),.p2(p2),.p3(p3),.p4(p4),.p5(p5),.p6(p6),.p7(p7),.p8(p8),///pi always decides number of rows which is fixed (i.s 3)//////////////////
        .q0(q0),.q1(q1),.q2(q2),.q3(q3),.q4(q4),.q5(q5),.q6(q6),.q7(q7),.q8(q8)////qi always decides the number of collums which maximum value goes to 1024//
 );
 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////instantiation of mac9_unit//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg signed [31:0] I0,I1,I2,I3,I4,I5,I6,I7,I8;
reg signed [31:0] W0,W1,W2,W3, W4,W5,W6,W7,W8;
wire signed [31:0]out_con;
reg signed[31:0]rellu_final;
(* keep_hierarchy = "yes" *)mac9  MAC (
    .clk(clk),
    .reset(reset),
    .I0(I0), .I1(I1), .I2(I2), .I3(I3), .I4(I4), .I5(I5), .I6(I6), .I7(I7),.I8(I8),
    .W0(W0), .W1(W1), .W2(W2), .W3(W3), .W4(W4), .W5(W5), .W6(W6), .W7(W7), .W8(W8),
    .out_con(out_con)
);
///////////out_rellu  this is not actually rellu output we do not change the code again//so do not use this value any here///////////
///////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////instantiation of pqindex_generetor//////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg start_pq;
wire[2:0]pp,qq;
wire done_pq;
(* keep_hierarchy = "yes" *)pqindex_generetor#(.n(n)) pq_ig(
      .clk(clk),
      .reset(reset),
      .start_pq(start_pq),
      .p(pp),
      .q(qq),
     .done_pq(done_pq)
    );
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////instantiation of pool_pq_index//////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
 reg start_pool;
 wire[2:0]a0,a1,a2,a3;
 wire[10:0]b0,b1,b2,b3;
 wire pool_row;
 wire max_pool_complete;
(* keep_hierarchy = "yes" *)pool_pq_index#(.n(n)) ppi(
         .clk(clk),
         .reset(reset),
         .start_pool(start_pool),
         .a0(a0),.a1(a1),.a2(a2),.a3(a3),
         .b0(b0),.b1(b1),.b2(b2),.b3(b3),///nomber of collumn is sufficient
         .pool_row(pool_row),
         .max_pool_complete(max_pool_complete)   
    ); 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////instantiation of max_pool4///////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
reg signed[31:0]a,b,c,d; 
wire complete_max;
(* keep_hierarchy = "yes" *)max_pool4 mp4 (
          .clk(clk),
          .reset(reset),
          .a(a),
          .b(b),
          .c(c),
          .d(d),
          .max_out(max_out),
          .complete_max(complete_max)
);  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////instantiation of mem_store_index///////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
wire mem_store_done;
(* keep_hierarchy = "yes" *)mem_store_index #(.n(n), .MA(MA)) msi (
    .clk(clk),
    .reset(reset),
    .start_mem_store(start_mem_store),
    .mem_store_address(mem_store_address),  // maximum memory address is 2**15
    .mem_store_done(mem_store_done)
);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////main  block//////////////////////main block////////////////main block/////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always@(posedge clk)begin
       if(reset)begin
///////////upto all these variables are useful for depthwise convolution///////////////////////////////////////////////////////      
          ik<=0;ir<=k-1;ic<=0;
          din_a<=0;din_b<=0;
          icount<=0; we_a<=0;///becasuse we need always read from portA////////////////////////////////////////////////////////
          image_row_complete<=0;
          karnel_complete<=0;
          con_rellu_complete<=0;
          kkbase_address<=kbase_address;///one time set by user//////////////
          iibase_address<=ibase_address;///one time set by user//////////////
          chh_no<=1;///one time initializetion///////////////////////////////
          con_add<=0;////at the initial time it is required to do 0//////////
          startb<=0;//// this initializetion is required which deactive portB
          portB_address<=18'd10;//it cam be set or user defined//////////
          
//////////all these variables are used for rellu  max pooling and storeing///////////////////////////////////////////////////
          ch_convolution<=0;                 
          irr<=k-2;icc<=0;rellu_final<=0;
          line[0][0]<=0;///adjusting purpose it is essential/////////////////////////////////////////////////////////////////
          start_mem_store<=0;  iicount<=0;
          portA_address<=0; ///to keep x value better keep 0 value that the idea//////////////////////////////////////
 ///////////////this variable not need repeart//////////////////////////////////////////////////////////////////////////////        
          maxpoo1_store_address_v<=maxpoo1_store_address;//one time required//
          fi_no<=1;multi_ch_multi_fil_complete<=0;//////one time required////
         
       end
       else begin
        case(state)
///////////////////////////////////karnel updateing///////////////////////////////////////////////////////      
          s0:begin
            portA_address<=kkbase_address+ik;
            ik<=ik+1;
            if(ik>=2)begin
               karnel_matrix[ik-2]<=dout_a;///mem[kbase_address+ik];
               if(ik>k*k+1)begin
                  karnel_complete<=1; 
              end
           end
        end  
//////////////////////////////////////////////////////////////////////////////////////////////////////////   
        //total_image_pixel=n*n 
        s1:begin
        if(icount<=n*n+11 && karnel_complete==1)begin //WE ADD 12 BECAUSE mac has latency 4/////extra latency
 //////////////////////////////////////////////////////////////////////////////////////////       
 //////the job of this section is: make n*n matrix useing 3*n register makeing equilibuim balance of icount//
             icount<=icount+1;
             portA_address<=iibase_address+icount;
             if(icount==1)begin
                ir<=k-1;ic<=0;
             end
             if(icount<=n*n+1 && icount>1)begin  
                line[ir][ic]<=dout_a; 
                if(ic==n-1)begin
                   ic<=0;
                   image_row_complete<=1;
                   if(ir==0) begin
                      ir<=k-1;
                   end
                   else begin
                      ir<=ir-1;
                   end
               end
               if(ic<n-1)begin
                    ic<=ic+1;
                    image_row_complete<=0;
               end
           end  
 ///////////////////////////////////////////////////////////////////////////////////////////////           
////////////////////////////////////////////////////////////////////////////////////////////////    
        if(icount==2*n)begin  //// equatin will be 2*n+4-6=2*n-2//herex=2*n//////////////////////
                start_pq<=1;
            end
            //////////here actually exactly right values captureing will be started after icount==16
            /////before icount==16, we can expect mac output values are zero.
            ina<=pp;
            inb<=qq;
            W0<=karnel_matrix[0];W1<=karnel_matrix[1];W2<=karnel_matrix[2];
            W3<=karnel_matrix[3];W4<=karnel_matrix[4];W5<=karnel_matrix[5];
            W6<=karnel_matrix[6];W7<=karnel_matrix[7];W8<=karnel_matrix[8];
            
            I0<=line[p0][q0];I1<=line[p1][q1];I2<=line[p2][q2];
            I3<=line[p3][q3];I4<=line[p4][q4];I5<=line[p5][q5];
            I6<=line[p6][q6];I7<=line[p7][q7];I8<=line[p8][q8];
            if(icount==n*n+8)begin//WE ADD 12 BECAUSE mac has latency 4/////extra latency
                con_rellu_complete<=1;
            end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
           if(icount==2*n+9)begin
               startb<=1;
            end
            if(startb==1)begin   
               portB_address<=portB_address+1;
               din_b<=out_con;
            end
            if(icount==n*n+9)begin
               startb<=0;
            end
            
///////////////////////////////////////////////////////////////////////////////////////////////////////////////    
         end 
 end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////here we have to adjusting ibase_address and kbase_address and initialised all the parameter again//
       s2:begin
          ik<=0;ir<=k-1;ic<=0;
         // din_a<=0;//not required
          din_b<=0;start_pq<=0;
          icount<=0; we_a<=0;///becasuse we need always read from portA/////////////////////////////////////////
          image_row_complete<=0;
          karnel_complete<=0;
          con_rellu_complete<=0;
          kkbase_address<=kkbase_address+0;////here we can adjust the karnel address for different filter//////
          iibase_address<=iibase_address+n_t-1;////here we can adjust the channel address for image////////////////
          ////ch1=R,ch2=G,ch3=B//n_t-1//address adjustable of image matrix of different channel///////////////////
          chh_no<=chh_no+1; 
          con_add<=1;/////////this is very important parametrt just k of BRAM/////////////////////////////////
          portB_address<=18'd10 + chh_no ;
          portBB_address<=18'd10 + chh_no ;
          
          
       end  
       //////////////this state is created only for addusteing the address for the next operation/////////////////
       s3:begin
          portA_address<=portB_address+1;
          
       end   
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////in this state we will be performeing rellu maxpooling and storeing operation//////////////////////
       s4:begin
          if(ch_convolution==1 )begin
                iicount<=iicount+1;
                portA_address<=portA_address+1;
                if(portA_address>=portBB_address+1)begin
                     if(dout_a[31]==1) begin
                         rellu_final<=0;
                     end
                     else begin
                         rellu_final<=dout_a;
                     end
                end    
 /////////////////////////this block will help to fill the line_pool register//////////////////////////////   
               if(iicount>=2) begin
                  line[irr][icc]<=rellu_final;
                  if(icc==n-1)begin
                       icc<=0;
                       image_row_pool_complete<=1;
                       if(irr==0) begin
                           irr<=k-2;
                       end
                       else begin
                           irr<=irr-1;
                       end
                  end
                if(icc<n-1)begin
                   icc<=icc+1;
                   image_row_pool_complete<=0;
                end 
  /////////////selecting maximum value///////////////////////////////////////////////////////////////////// 
               if(iicount==n+2)begin
                    start_pool<=1;
               end    
               a<=line[a0][b0];
               b<=line[a1][b1];
               c<=line[a2][b2];
               d<=line[a3][b3];
               
/////////////selecting proper memorey address to store the values//////////////////////////////////////////          
               if(iicount==n+6)begin
                  start_mem_store<=1;
                   max_pool_store<=1;
                  //startb<=1; ////here portA used is bad idea//so i decide to use port B thats will be good/
                 // con_add<=0;
               end
               if(start_mem_store==1)begin
                  portB_address<=maxpoo1_store_address_v+mem_store_address;
                  din_b<=max_out;
              end         
          end  
      end
    end
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////
      s5:begin             
//////////all these variables are used for rellu  max pooling and storeing//////////////////////////////////// 
///////////multi filter preparetion/////////////////////////////////////////////////////////////////////////  
          ch_convolution<=0;       
          irr<=k-2;icc<=0;rellu_final<=0;
          line[0][0]<=0;///adjusting purpose it is essential//////////////////////////////////////////////////
          iicount<=0;start_pool<=0;
          start_mem_store<=0;we_a<=0;
          maxpoo1_store_address_v<=portB_address+1;
          chh_no<=1;con_add<=0;startb<=0;
          fi_no<=fi_no+1; max_pool_store<=0;
       end   
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      s6:begin
         portB_address<=18'd10;//portA is used for only reading purpose ///portB is used read+write+accumulate//
         din_b<=0;
         //at state1 //to store max pooling result to the same memorey again it is used only for writting purpose
         //once time in state 4//inthis  state it is necessery to adjust it///
         // 1000 is the stored address of convolution(multi ch for fast filter)//latter on we can change it///////
      end     
      s7:begin
         
      end
   
      endcase
      end  
end 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////   
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////state control combinetional block////////////////////////////////////////////////////////
always@(posedge clk)begin
  if(reset)begin
     state<=s0;
  end
  else begin
     case(state)
 ////////////////////////////////////////////////////    
     s0:begin
        if(karnel_complete==1)begin
          state<=s1;
        end
        else begin
          state<=s0;
        end
     end 
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////    
     s1:begin
        if(icount>=n*n+10 && con_rellu_complete )begin //WE ADD 12 BECAUSE mac has latency 4/////extra latency
           state<=s2;
        end
        else begin
           state<=s1;
        end    
     end
     s2:begin
        if(chh_no==ch)begin
           ch_convolution<=1;////////// this signal will confirm the finiseing line of 3d convolution////////
           state<=s3;
        end
        else begin
           state<=s0;
        end
     end 
    s3:begin
           state<=s4;
    end 
    s4:begin
       if(mem_store_done==1)begin
           state<=s5;
       end
       else begin
           state<=s4;
       end
    end
    s5:begin
       if(fi_no==fi)begin
         multi_ch_multi_fil_complete<=1;
         state<=s7;
       end
       else begin
         state<=s6;
       end
    end
    s6:begin
       state<=s0;
    end
    s7:begin
       state<=s7;
    end
    
//////////////////////////////////////////////////////////
    endcase
   end 
end     
endmodule