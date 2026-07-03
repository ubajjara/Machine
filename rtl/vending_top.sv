module vending_top(
    input  logic [1:0] coin_in,
    input  logic [1:0] sel_item,
    input  logic       confirm,
    input  logic       cancel,
    input  logic       clk,
    input  logic       rst,

    output logic       dispense,
    output logic [7:0] change_out,
    output logic       error,
    output logic [7:0] display,
    output logic [2:0] state_out
);

    logic       can_sell;
    logic       credit_load;
    logic       credit_clear;
    logic       mem_read;
    logic       mem_write;

    logic [7:0] credit;
    logic [7:0] price;
    logic [7:0] stock;
    logic [7:0] change;

    control_unit unit_inst (
        .clk          (clk),
        .rst          (rst),
        .coin_in      (coin_in),
        .confirm      (confirm),
        .cancel       (cancel),
        .can_sell     (can_sell),
        .credit_load  (credit_load),
        .credit_clear (credit_clear),
        .mem_read     (mem_read),
        .mem_write    (mem_write),
        .dispense     (dispense),
        .error        (error),
        .state_out    (state_out)
    );

    registrador_credito credit_inst (
        .clk          (clk),
        .rst          (rst),
        .credit_load  (credit_load),
        .credit_clear (credit_clear),
        .coin_in      (coin_in),
        .credit       (credit)
    );

    memory memoria_inst (
        .clk       (clk),
        .rst       (rst),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .sel_item  (sel_item),
        .price     (price),
        .stock     (stock)
    );

    Comparador comp_inst (
        .credit   (credit),
        .price    (price),
        .stock    (stock),
        .can_sell (can_sell)
    );

    subtrator sub_inst (
        .credit (credit),
        .price  (price),
        .change (change)
    );


    assign display = credit;

    always_ff @(posedge clk) begin
        if (rst) begin
            change_out <= 8'd0;
        end else if (cancel) begin

            change_out <= credit;
        end else if (state_out == 3'b100) begin

            change_out <= change;
        end else if (state_out == 3'b101) begin

            change_out <= credit;
        end
    end

endmodule
