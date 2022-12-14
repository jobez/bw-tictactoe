%lang starknet
from src.main import Game, check_winner, init_new_game, player_to_game_id, make_move, game_id_to_game, join_game
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin

@external
func test_check_winner{syscall_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}() {
   // value to pass
    let check_one = check_winner(448);
    assert check_one = 1;

    let check_two = check_winner(85);
    assert check_two = 1;
   

    return ();
}

@external
func test_main2{syscall_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr : HashBuiltin*}() {
   // value to pass
    %{ stop_prank_callable = start_prank(123) %}
    alloc_locals;
    init_new_game();    
    let game_idx : felt = player_to_game_id(123);
    make_move(game_idx, 1);
    let updated_game : Game = game_id_to_game(game_idx);
   
    %{ print(f"{ids.updated_game.player_x=} {ids.updated_game.state_x=} {ids.updated_game.last_mover=}") 
    %}
    
    assert updated_game.player_x = 123;
    assert updated_game.state_x = 1;

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(124) %}
    join_game(game_idx);
    make_move(game_idx, 1);
    let updated_game : Game = game_id_to_game(game_idx);
   

   %{ print(f"{ids.updated_game.player_o=} {ids.updated_game.state_o=} {ids.updated_game.last_mover=}") 
    %}

    assert updated_game.player_o = 124;
    assert updated_game.state_o = 1;
    %{ expect_revert(error_message="not your turn") %}
    make_move(game_idx, 3);

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(123) %}
    make_move(game_idx, 2);

    let updated_game : Game = game_id_to_game(game_idx);
    assert updated_game.winner = 2;

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(124) %}
    %{ expect_revert(error_message="game over") %}
    make_move(game_idx, 7);
    %{ stop_prank_callable() %}


    %{ stop_prank_callable() %}

    // now we check that upon finishing both players can start their own games

    %{ stop_prank_callable = start_prank(123) %}
    init_new_game();    
    %{ stop_prank_callable() %}


    %{ stop_prank_callable = start_prank(124) %}
    init_new_game();    
    %{ stop_prank_callable() %}

    return ();
}

@external
func test_move_validation_must_be_within_bounds_of_board{syscall_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr : HashBuiltin*}() {
   // value to pass
    %{ stop_prank_callable = start_prank(123) %}
    alloc_locals;
    init_new_game();    
    let game_idx : felt = player_to_game_id(123);
    make_move(game_idx, 1);
    let updated_game : Game = game_id_to_game(game_idx);
   
  
    assert updated_game.player_x = 123;
    assert updated_game.state_x = 1;

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(124) %}

    join_game(game_idx);
    make_move(game_idx, 2);

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(123) %}



    %{ expect_revert(error_message="move is not on the board") %}
    make_move(game_idx, 513);
    %{ stop_prank_callable() %}



    return ();
}

@external
func test_move_validation_board_state_must_change{syscall_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr : HashBuiltin*}() {
   // value to pass
    %{ stop_prank_callable = start_prank(123) %}
    alloc_locals;
    init_new_game();    
    let game_idx : felt = player_to_game_id(123);
    make_move(game_idx, 1);
    let updated_game : Game = game_id_to_game(game_idx);
   
  
    assert updated_game.player_x = 123;
    assert updated_game.state_x = 1;

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(124) %}

    join_game(game_idx);
    make_move(game_idx, 2);

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(123) %}



    %{ expect_revert(error_message="board state unchanged") %}
    make_move(game_idx, 1);
    %{ stop_prank_callable() %}



    return ();
}

@external
func test_move_validation_board_state_must_succeed_prior_state{syscall_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr : HashBuiltin*}() {
   // value to pass
    %{ stop_prank_callable = start_prank(123) %}
    alloc_locals;
    init_new_game();    
    let game_idx : felt = player_to_game_id(123);
    make_move(game_idx, 1);
    let updated_game : Game = game_id_to_game(game_idx);
   
  
    assert updated_game.player_x = 123;
    assert updated_game.state_x = 1;

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(124) %}

    join_game(game_idx);
    make_move(game_idx, 2);

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(123) %}



   %{ expect_revert(error_message="board state must succeed prior state") %}
    make_move(game_idx, 0);
    %{ stop_prank_callable() %}



    return ();
}



@external
func test_move_validation_deny_more_than_one_move_at_once{syscall_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr : HashBuiltin*}() {
   // value to pass
    %{ stop_prank_callable = start_prank(123) %}
    alloc_locals;
    init_new_game();    
    let game_idx : felt = player_to_game_id(123);
    make_move(game_idx, 1);
    let updated_game : Game = game_id_to_game(game_idx);
   
  
    assert updated_game.player_x = 123;
    assert updated_game.state_x = 1;

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(124) %}

    join_game(game_idx);
    make_move(game_idx, 2);

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(123) %}



    %{ expect_revert(error_message="not a valid discrete move from prior board state") %}
     make_move(game_idx, 7);
    %{ stop_prank_callable() %}



    return ();
}

@external
func test_move_validation_move_already_taken_by_opposition{syscall_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr : HashBuiltin*}() {
   // value to pass
    %{ stop_prank_callable = start_prank(123) %}
    alloc_locals;
    init_new_game();    
    let game_idx : felt = player_to_game_id(123);
    make_move(game_idx, 1);
    let updated_game : Game = game_id_to_game(game_idx);
   
  
    assert updated_game.player_x = 123;
    assert updated_game.state_x = 1;

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(124) %}

    %{ expect_revert(error_message="move is already taken by opposition") %}
    join_game(game_idx);
    make_move(game_idx, 1);
    %{ stop_prank_callable() %}



    return ();
}

@external
func test_move_validation_board_state_must_not_allow_same_move{syscall_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr : HashBuiltin*}() {
   // value to pass
    %{ stop_prank_callable = start_prank(123) %}
    alloc_locals;
    init_new_game();    
    let game_idx : felt = player_to_game_id(123);
    make_move(game_idx, 4);
    let updated_game : Game = game_id_to_game(game_idx);
   
  
    assert updated_game.player_x = 123;
    assert updated_game.state_x = 4;

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(124) %}

    join_game(game_idx);
    make_move(game_idx, 2);

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(123) %}



   %{ expect_revert(error_message="move is already made by yourself") %}
    make_move(game_idx, 8);
    %{ stop_prank_callable() %}



    return ();
}


