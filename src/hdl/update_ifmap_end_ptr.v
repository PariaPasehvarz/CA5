module update_ifmap_end_ptr (
    input [1:0] read_addr_status,
    output update_end_ptr
);
    assign update_end_ptr = read_addr_status == 2'b10; //if status is empty
endmodule