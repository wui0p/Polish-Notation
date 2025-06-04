//2025 FPGA FINAL
//Topic：Polish Notation
//by 4112064029 吳聲寬

module PN(
           input clk,
           input rst_n,
           input [1:0] mode,
           input operator,
           input [2:0] in,
           input in_valid,
           output out_valid,
           output signed [31:0] out
       );

//================================================================
//   PARAMETER/INTEGER
//================================================================
//for mode
parameter PRE_MULTI = 0;
parameter POST_MULTI = 1;
parameter PRE_SINGLE = 2;
parameter POST_SINGLE = 3;

//for operator
parameter PLUS = 0; //+
parameter MINUS = 1; //-
parameter MULTI = 2; //*
parameter ABS = 3; //|a+b|

integer i; //SIZE of the array
integer j; //first layer of bubble sort
integer k; //second layer of bubble sort

//================================================================
//   REG/WIRE
//================================================================
reg [1:0] mode_state;   //regester for mode

reg signed [31:0] input_save [0:15];
reg [3:0] oper_save [0:15];     //save the address of where the operators are in input_save
reg [3:0] cycle = 0;
reg [3:0] oper_num = 0;
reg signed [31:0] answer [0:3];

reg signed [31:0] temp; //for bubble sort

reg out_v_reg;              //regester for out_valid
reg signed [31:0] out_reg;  //regester for out
reg [2:0] out_num = 0;

reg sort_flag = 0;      //mark if input is finished, start sorting
reg finish_flag = 0;    //mark if sorting is finished, start output

//================================================================
//   MODE
//================================================================
always @(*) begin
    if(mode==PLUS || mode==MINUS || mode==MULTI || mode==ABS)
        mode_state <= mode;
end


//================================================================
//   SAVE INPUT
//================================================================
always @(posedge clk) begin
    if(in_valid) begin
        //if it is SINGLE output mode, we need to store where the operator is at in input_save
        if(mode_state == PRE_SINGLE || mode_state == POST_SINGLE) begin
            if(operator) begin
                oper_save[oper_num] = cycle;
                oper_num = oper_num + 1;
            end
        end

        input_save[cycle] <= in;
        cycle <= cycle + 1;
    end
end


//================================================================
//   CALC ANSWERS
//================================================================
always @(negedge in_valid) begin
    case(mode_state)
        PRE_MULTI: begin
            for(i=0 ; i<cycle/3 ; i=i+1) begin
                case(input_save[3*i])
                    PLUS: answer[i] = input_save[3*i+1] + input_save[3*i+2];
                    MINUS: answer[i] = input_save[3*i+1] - input_save[3*i+2];
                    MULTI: answer[i] = input_save[3*i+1] * input_save[3*i+2];
                    ABS: answer[i] = input_save[3*i+1] + input_save[3*i+2];
                endcase
            end
            sort_flag = 1;
        end
        POST_MULTI: begin
            for(i=0 ; i<cycle/3 ; i=i+1) begin
                case(input_save[3*i+2])
                    PLUS: answer[i] = input_save[3*i] + input_save[3*i+1];
                    MINUS: answer[i] = input_save[3*i] - input_save[3*i+1];
                    MULTI: answer[i] = input_save[3*i] * input_save[3*i+1];
                    ABS: answer[i] = input_save[3*i] + input_save[3*i+1];
                endcase
            end
            sort_flag = 1;
        end
        PRE_SINGLE: begin
            for(i=oper_num-1 ; i>=0 ; i=i-1) begin
                case(input_save[oper_save[i]])
                    PLUS: input_save[oper_save[i]] = input_save[oper_save[i]+1] + input_save[oper_save[i]+2];
                    MINUS: input_save[oper_save[i]] = input_save[oper_save[i]+1] - input_save[oper_save[i]+2];
                    MULTI: input_save[oper_save[i]] = input_save[oper_save[i]+1] * input_save[oper_save[i]+2];
                    ABS: begin
                        if(input_save[oper_save[i]+1] + input_save[oper_save[i]+2] < 0)
                            input_save[oper_save[i]] = (-1) * (input_save[oper_save[i]+1] + input_save[oper_save[i]+2]);
                        else
                            input_save[oper_save[i]] = input_save[oper_save[i]+1] + input_save[oper_save[i]+2];
                    end
                endcase
                
                //shuffle input_save back to a full array
                for(j=oper_save[i] ; j+3<cycle ; j=j+1) begin
                    input_save[j+1] = input_save[j+3];
                end
                cycle = cycle - 2;

            end
            finish_flag = 1;
        end
        POST_SINGLE: begin
            for(i=0 ; i<oper_num ; i=i+1) begin
                case(input_save[oper_save[i]-2*i])
                    PLUS: input_save[oper_save[i]-2*i-2] = input_save[oper_save[i]-2*i-2] + input_save[oper_save[i]-2*i-1];
                    MINUS: input_save[oper_save[i]-2*i-2] = input_save[oper_save[i]-2*i-2] - input_save[oper_save[i]-2*i-1];
                    MULTI: input_save[oper_save[i]-2*i-2] = input_save[oper_save[i]-2*i-2] * input_save[oper_save[i]-2*i-1];
                    ABS: begin
                        if(input_save[oper_save[i]-2*i-2] + input_save[oper_save[i]-2*i-1] < 0)
                            input_save[oper_save[i]-2*i-2] = (-1) * (input_save[oper_save[i]-2*i-2] + input_save[oper_save[i]-2*i-1]);
                        else
                            input_save[oper_save[i]-2*i-2] = input_save[oper_save[i]-2*i-2] + input_save[oper_save[i]-2*i-1];
                    end
                endcase

                //shuffle input_save back to a full array
                for(j=oper_save[i]-2*i-2 ; j+3<cycle ; j=j+1) begin
                    input_save[j+1] = input_save[j+3];
                end
                cycle = cycle - 2;
                    

            end
            finish_flag = 1;
        end
    endcase
end

//================================================================
//   BUBBLE SORT (MAINLY CREATED BY CHATGPT)
//================================================================
always @(posedge clk) begin
    if(sort_flag) begin
        case(mode_state)
            PRE_MULTI: begin
                for(j=0 ; j<i-1 ; j=j+1) begin
                    for(k=0 ; k<i-j-1 ; k=k+1) begin
                        if(answer[k] < answer[k+1]) begin
                            temp = answer[k];
                            answer[k] = answer[k+1];
                            answer[k+1] = temp;
                        end
                    end
                end
            end
            POST_MULTI: begin
                for (j = 0; j < i - 1; j = j + 1) begin
                    for (k = 0; k < i - j - 1; k = k + 1) begin
                        if (answer[k] > answer[k+1]) begin
                            temp = answer[k];
                            answer[k] = answer[k+1];
                            answer[k+1] = temp;
                        end
                    end
                end
            end
        endcase
        sort_flag = 0;
        finish_flag = 1;
    end
end

//================================================================
//   OUTPUT
//================================================================
assign out = out_reg;
assign out_valid = out_v_reg;

always @(posedge clk) begin
    if(finish_flag) begin
        if(mode_state == PRE_MULTI || mode_state == POST_MULTI) begin
            if(out_num < cycle/3) begin
                out_v_reg = 1;
                out_reg = answer[out_num];
                out_num = out_num + 1;
            end else begin
                out_v_reg <= 0;
                out_reg <= 0;
                out_num <= 0;
                cycle <= 0;
                finish_flag <= 0;
            end
        end else begin
            if(!out_v_reg) begin
                out_reg = input_save[0];
                out_v_reg = 1;
            end else begin
                out_reg <= 0;
                out_v_reg <= 0;
                oper_num <= 0;
                cycle <= 0;
                finish_flag <= 0;
            end
        end
    end
end


//================================================================
//   RESET
//================================================================
always @(negedge rst_n) begin
    if(!rst_n) begin
        out_v_reg <= 0;
        out_reg <= 0;
        out_num <= 0;
        cycle <= 0;
        finish_flag <= 0;
        sort_flag <= 0;
        oper_num <= 0;
    end
end

endmodule
