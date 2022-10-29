%lang starknet
from src.main import check_winner
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin

@external
func test_main{syscall_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}() {
   // value to pass
    let check_one = check_winner(448);
    assert check_one = 1;

    let check_two = check_winner(85);
    assert check_two = 1;
    %{ print(f"{ids.check_two=}") 
    %}
    

    return ();
}
