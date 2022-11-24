%lang starknet

from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.bitwise import bitwise_and, bitwise_xor
from starkware.cairo.common.math_cmp import is_not_zero, is_le_felt
from starkware.cairo.common.pow import pow
from starkware.cairo.common.math import unsigned_div_rem, assert_not_zero, assert_not_equal
from starkware.cairo.common.alloc import alloc

const PLAYER_X = 1;
const PLAYER_O = 2;

struct Game {
    player_x: felt,
    player_o: felt,
    state_x: felt,
    state_o: felt,
    last_mover: felt,
    winner: felt,
}

@event
func game_over(
    game_id: felt,
    role: felt,
    winner: felt
) {
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
    
func get_nth_bit{bitwise_ptr : BitwiseBuiltin*, range_check_ptr : felt}(value, n) -> felt {
   let (pow2n) = pow(2, n);
   let (and_val) = bitwise_and(value, pow2n);
    if (and_val == pow2n) {
        return (1);
    } else {
        return (0);
    }

    

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

//   %{ print(f"passing value: {ids.state=} {ids.win_state=} {ids.win_check=}") %}
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
    
   game_state.write(game_idx+1, new_game);
   player_to_game_idx.write(address, game_idx+1); 
   game_count.write(game_idx+2); 

   return (); 
}

@external
func join_game{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(game_idx: felt){
   let address : felt = get_caller_address();
   let game : Game = game_state.read(game_idx);
   with_attr error_message ("a game must exist to join") {
       assert_not_zero(game.player_x);
   }

    with_attr error_message ("you cannot join the same game") {
       assert_not_equal(game.player_x, address);
   }

   with_attr error_message ("a spot must be available to join") {
       assert game.player_o = 0;
   }

   let joined_game : Game = Game(game.player_x, address, game.state_x, game.state_o, game.last_mover, game.winner);
   game_state.write(game_idx, joined_game); 
  player_to_game_idx.write(address, game_idx);

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


func is_pow_of_two{bitwise_ptr: BitwiseBuiltin*}(number: felt) -> (bool : felt) {

    let number_minus_one = number - 1;
    let (pow_two_check) = bitwise_and(number, number_minus_one);

    if (pow_two_check == 0) {
        return (bool=1);
    } else {
    
        return (bool=0);
    
    }

}

func log2{bitwise_ptr: BitwiseBuiltin*, range_check_ptr}(number: felt, current : felt, log: felt) -> (final_log : felt) {

    if (current == 0) {
    
        return (final_log=log);
        
    } 

    let is_this_pow_of_two : felt = get_nth_bit(number, current-1);

    if (is_this_pow_of_two == 1) {

        return (final_log=current-1);
    
    }

    let (new_log) = log2(number, current-1, log);
    
    return (final_log=new_log);
}


func validate_move{bitwise_ptr: BitwiseBuiltin*, range_check_ptr}(possible_move : felt, opposing_board_state : felt) {
        alloc_locals;
        with_attr error_message ("board state must change") {
           assert_not_zero(possible_move); 
        }

        let valid_possible_move : felt = is_pow_of_two(possible_move);
    
        with_attr error_message ("not a valid discrete move from prior board state") {
            // is the delta only one move forward?
            // for role, is possible_state - role_board_state a power of two?, is so, which power?

            assert valid_possible_move = 1;
        }    

        // for role, is possible_state - role_board_state a power of two?, is so, which power?
        let (local move_on_board) = log2(possible_move, 8, -1);

        with_attr error_message ("move is not on the board") {
            // is the delta only one move forward?
            // for role, is possible_state - role_board_state a power of two?, is so, which power?

           assert_not_equal(move_on_board, -1);
        }

        // did the other player already make a move in that spot?
        let move_is_taken : felt = get_nth_bit(opposing_board_state, move_on_board);
       %{ print(f"move check: {ids.possible_move=} {ids.move_on_board=} {ids.opposing_board_state=} {ids.move_is_taken=} ") %}

        with_attr error_message ("move is already taken by opposition") {
            // is the delta only one move forward?
            // for role, is possible_state - role_board_state a power of two?, is so, which power?

           assert_not_equal(move_is_taken, 1);
        }

    return ();
}


func validate_moves{bitwise_ptr: BitwiseBuiltin*, range_check_ptr}(role: felt, o_board_state : felt, x_board_state : felt, possible_state : felt) {
 
    alloc_locals;
    
   if (role == PLAYER_X) {
        let possible_move : felt = possible_state - x_board_state;
        validate_move(possible_move, o_board_state);
        tempvar bitwise_ptr=bitwise_ptr;
        tempvar range_check_ptr=range_check_ptr;
        

    
    } else {
       let possible_move : felt = possible_state - o_board_state;
       validate_move(possible_move, x_board_state);
       tempvar bitwise_ptr=bitwise_ptr;
       tempvar range_check_ptr=range_check_ptr;
    }

    tempvar bitwise_ptr=bitwise_ptr;
    tempvar range_check_ptr=range_check_ptr;


    // is the one move forward attempting to be made already 'occupied'?
    // if the move is a valid power of two, take the power and see if it exists in other_role_board_state
    // if not, we gucci

    return ();

}

func handle_end_game{ syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(game_ended : felt, maybe_winner : felt, maybe_winner_role : felt, game_id : felt, game : Game) {
    if (game_ended == 0) {
       tempvar syscall_ptr=syscall_ptr;
       tempvar pedersen_ptr=pedersen_ptr;
       tempvar range_check_ptr=range_check_ptr;
    } else {
       player_to_game_idx.write(game.player_x, 0);
       player_to_game_idx.write(game.player_o, 0);
       game_over.emit(game_id=game_id, role=maybe_winner_role, winner=maybe_winner);
       tempvar syscall_ptr=syscall_ptr;
       tempvar pedersen_ptr=pedersen_ptr;
       tempvar range_check_ptr=range_check_ptr;    
       

    } 

    
    return ();
}

func update_game{bitwise_ptr: BitwiseBuiltin*, range_check_ptr}(role : felt, prior_game : Game, new_move :felt) -> (new_game: Game, end_game: felt) {
    alloc_locals;
    validate_moves(role, prior_game.state_o, prior_game.state_x, new_move);
    if (role == PLAYER_X) {
       let winning_move = check_winner(new_move); 
       let maybe_won = winning_move * role; 
       let new_game = Game(prior_game.player_x, prior_game.player_o, new_move, prior_game.state_o, PLAYER_X, maybe_won);
       return (new_game=new_game, end_game=winning_move);
    } else {
       let winning_move = check_winner(new_move); 
       let maybe_won = winning_move * role;
       let new_game = Game(prior_game.player_x, prior_game.player_o, prior_game.state_x, new_move, PLAYER_O, maybe_won);
       return (new_game=new_game, end_game=winning_move);
    }

}

@external
func make_move{syscall_ptr : felt*, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr : HashBuiltin*, range_check_ptr}(game_idx: felt, updated_game_state : felt) {
   alloc_locals;
   let address : felt = get_caller_address();     
   assert_not_zero(address);     
   let game : Game = game_state.read(game_idx); 
   let role : felt = derive_address_role(game, address);
   
    
    enforce_permissable_move(role, game);

    let (new_game : Game, game_over : felt) = update_game(role, game, updated_game_state);

    game_state.write(game_idx, new_game);   
    
    handle_end_game(game_over, address, role, game_idx, new_game);
    

    return ();

}
