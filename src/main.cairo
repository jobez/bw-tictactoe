%lang starknet

from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.bitwise import bitwise_and, bitwise_xor
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.pow import pow
from starkware.cairo.common.math import unsigned_div_rem, assert_not_zero, assert_not_equal
from starkware.cairo.common.alloc import alloc

const PLAYER_X = 1;
const PLAYER_O = 2;

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
    // 111 000 000
    assert winners[1] = 56;
    // 000 111 000
    assert winners[2] = 7;
    // 000 000 111
    assert winners[3] = 292;
    // 100 100 100
    assert winners[4] = 146;
    // 010 010 010
    assert winners[5] = 73;
    // 001 001 001
    assert winners[6] = 273;
    // 100 010 001
    assert winners[7] = 84;
    // 001010100

    let res : felt = _check_winner(state=state, idx=7, winners=winners);
    return (res);

}

struct Game {
    player_x: felt,
    player_o: felt,
    state_x: felt,
    state_o: felt,
    last_mover: felt,
    winner: felt,
}


@storage_var 
func player_to_game_idx(player: felt) -> (game_idx: felt) {
}

@storage_var
func game_count() -> (gc: felt) {
}

@storage_var
func game_state(idx: felt) -> (res: Game) {
}    

@view 
func player_to_game_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (game_idx: felt) {
   let game_idx : felt = player_to_game_idx.read(address);
   return (game_idx=game_idx); 
    
}

@view 
func game_id_to_game{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(game_idx : felt) -> (game: Game) {
    let game : Game = game_state.read(game_idx);
    return (game=game);
}

@external
func init_new_game{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() {
   let address : felt = get_caller_address();     
   let game_idx : felt = game_count.read();

   assert_not_zero(address);     
    
   let potential_game_idx : felt = player_to_game_idx.read(address);
 
   with_attr error_message ("a player can only have one active game") {
        assert potential_game_idx = 0;
   }

 %{ print(f"passing value: {ids.address=} {ids.game_idx=} ") %}
   let new_game : Game = Game(address, 0, 0, 0, 0, 0);
    
   game_state.write(game_idx, new_game);
   player_to_game_idx.write(address, game_idx); 
   game_count.write(game_idx+1); 

   return (); 
}

@external
func join_game{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(game_idx: felt){
   let address : felt = get_caller_address();
   let game : Game = game_state.read(game_idx);
   with_attr error_message ("a game must exist to join") {
       assert_not_zero(game.player_x);
   }

   with_attr error_message ("a spot must be available to join") {
       assert game.player_o = 0;
   }

   let joined_game : Game = Game(game.player_x, address, game.state_x, game.state_o, game.last_mover, game.winner);
   game_state.write(game_idx, joined_game); 

   return (); 
}

func derive_address_role(game : Game, address : felt) -> felt {
    if (address == game.player_x) {
        return (PLAYER_X);
    
    }

    if (address == game.player_o) {
        return (PLAYER_O);
        
    }

   with_attr error_message ("this player is not registered in this game") {
        assert 1 = 0;
   }    
   
   return (0); 

}

func enforce_permissable_move(role: felt, game: Game) {

   with_attr error_message ("not your turn") {
      assert_not_equal(role, game.last_mover);
   }

   with_attr error_message ("game over") {
      assert game.winner = 0;
   }    

    return ();
}


@external
func make_move{syscall_ptr : felt*, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr : HashBuiltin*, range_check_ptr}(game_idx: felt, updated_game_state : felt) {
   alloc_locals;
   let address : felt = get_caller_address();     
   assert_not_zero(address);     
   let game : Game = game_state.read(game_idx); 
   let role : felt = derive_address_role(game, address);
   enforce_permissable_move(role, game);

    if (role == PLAYER_X) {
       let winning_move = check_winner(game.state_x); 
       let maybe_won = winning_move * role;        
       let updated_game = Game(game.player_x, game.player_o, updated_game_state, game.state_o, PLAYER_X, maybe_won);
        game_state.write(game_idx, updated_game);    
    } else {
       let winning_move = check_winner(game.state_o); 
       let maybe_won = winning_move * role;
       let updated_game = Game(game.player_x, game.player_o, game.state_x, updated_game_state, PLAYER_O, maybe_won);
        game_state.write(game_idx, updated_game);    
    }


    return ();

}
