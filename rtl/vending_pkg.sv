package vending_pkg;

    parameter int CREDIT_WIDTH = 8;
    parameter int ITEM_WIDTH   = 2;
    parameter int STATE_WIDTH  = 3;
    parameter int NUM_ITEMS    = 4;
    parameter int MEM_WIDTH    = 16;

    typedef enum logic [STATE_WIDTH-1:0] {
        IDLE     = 3'b000,
        COLLECT  = 3'b001,
        CHECK    = 3'b010,
        DISPENSE = 3'b011,
        CHANGE   = 3'b100,
        ERROR    = 3'b101
    } state_t;

    localparam logic [CREDIT_WIDTH-1:0] COIN_NONE = 8'd0;
    localparam logic [CREDIT_WIDTH-1:0] COIN_25   = 8'd25;
    localparam logic [CREDIT_WIDTH-1:0] COIN_50   = 8'd50;
    localparam logic [CREDIT_WIDTH-1:0] COIN_100  = 8'd100;

    localparam logic [CREDIT_WIDTH-1:0] PRICE_CAFE  = 8'd25;
    localparam logic [CREDIT_WIDTH-1:0] PRICE_AGUA  = 8'd50;
    localparam logic [CREDIT_WIDTH-1:0] PRICE_SUCO  = 8'd75;
    localparam logic [CREDIT_WIDTH-1:0] PRICE_SNACK = 8'd100;

    localparam logic [CREDIT_WIDTH-1:0] STOCK_CAFE  = 8'd5;
    localparam logic [CREDIT_WIDTH-1:0] STOCK_AGUA  = 8'd5;
    localparam logic [CREDIT_WIDTH-1:0] STOCK_SUCO  = 8'd3;
    localparam logic [CREDIT_WIDTH-1:0] STOCK_SNACK = 8'd2;

    function automatic logic [CREDIT_WIDTH-1:0] coin_to_value(
        input logic [1:0] coin_in
    );
        case (coin_in)
            2'b00:   coin_to_value = COIN_NONE;
            2'b01:   coin_to_value = COIN_25;
            2'b10:   coin_to_value = COIN_50;
            2'b11:   coin_to_value = COIN_100;
            default: coin_to_value = COIN_NONE;
        endcase
    endfunction

endpackage