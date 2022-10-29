%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.bitwise import bitwise_and, bitwise_xor
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.pow import pow
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.alloc import alloc


func get_nth_bit{bitwise_ptr : BitwiseBuiltin*, range_check_ptr : felt}(value, n) -> felt {
   let (pow2n) = pow(2, n);
   let (and_val) = bitwise_and(value, pow2n);
   let res = is_not_zero(and_val);
   return (res);
}

func jhnn_flip(n : felt) -> felt {
   return (1 - n);

}

// let winners = [
//   448, // 111 000 000
//   56, // 000 111 000
//   7, // 000 000 111
//   292, // 100 100 100
//   146, // 010 010 010
//   73, // 001 001 001
//   273, // 100 010 001
//   84, // 001010100  

// ];

func _check_winner{bitwise_ptr: BitwiseBuiltin*}(state: felt, idx: felt, winners: felt*) -> felt {
    let win_state : felt = [winners];
    
    let win_check : felt = bitwise_and(state, win_state);

    %{ print(f"passing value: {ids.state=} {ids.win_state=} {ids.win_check=}") %}
    if (win_check == win_state) {
       return 1; 
    }

    if (idx == 0) {
       return (0); 
    } else {
       let result : felt =  _check_winner(state=state, idx=idx-1, winners=winners+1);
       return (result); 
    }
   
}

func check_winner{bitwise_ptr: BitwiseBuiltin*}(state: felt) -> felt {
    alloc_locals;
    let winners: felt* = alloc();

    assert winners[0] = 448;
    assert winners[1] = 56;
    assert winners[2] = 7;
    assert winners[3] = 292;
    assert winners[4] = 146;
    assert winners[5] = 73;
    assert winners[6] = 273;
    assert winners[7] = 84;

    let res : felt = _check_winner(state=state, idx=7, winners=winners);
    return (res);

}

struct Game {
    player_one: felt,
    player_two: felt,
    state_x: felt,
    state_o: felt,
    completed: felt,
}

@storage_var
func game_state(idx: felt) -> (res: Game) {
}    


