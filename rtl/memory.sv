module memory(
    input  logic       clk,
    input  logic       rst,

    input  logic       mem_read,
    input  logic       mem_write,
    input  logic [1:0] sel_item,

    output logic [7:0] price,
    output logic [7:0] stock
);
    import vending_pkg::*;

    logic [15:0] mem [0:NUM_ITEMS-1];

    initial begin
        mem[0] = {PRICE_CAFE,  STOCK_CAFE};
        mem[1] = {PRICE_AGUA,  STOCK_AGUA};
        mem[2] = {PRICE_SUCO,  STOCK_SUCO};
        mem[3] = {PRICE_SNACK, STOCK_SNACK};
    end

    always @(posedge clk) begin
        if (rst) begin
            mem[0] <= {PRICE_CAFE,  STOCK_CAFE};
            mem[1] <= {PRICE_AGUA,  STOCK_AGUA};
            mem[2] <= {PRICE_SUCO,  STOCK_SUCO};
            mem[3] <= {PRICE_SNACK, STOCK_SNACK};

            price <= 8'd0;
            stock <= 8'd0;
        end else begin

            if (mem_read) begin
                price <= mem[sel_item][15:8];
                stock <= mem[sel_item][7:0];
            end

            if (mem_write) begin
                if (mem[sel_item][7:0] > 8'd0) begin
                    mem[sel_item][7:0] <= mem[sel_item][7:0] - 8'd1;
                end
            end

        end
    end

endmodule