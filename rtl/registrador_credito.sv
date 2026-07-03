import vending_pkg::*;

module registrador_credito(
    input  logic       clk,
    input  logic       rst,

    input  logic       credit_load,
    input  logic       credit_clear,
    input  logic [1:0] coin_in,

    output logic [7:0] credit
);

    logic [7:0] coin_value;

    always_comb begin
        coin_value = coin_to_value(coin_in);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            credit <= 8'd0;
        end else if (credit_clear) begin
            credit <= 8'd0;
        end else if (credit_load) begin
            credit <= credit + coin_value;
        end
    end

endmodule