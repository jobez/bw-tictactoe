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
    make_move(game_idx, 33);
    let updated_game : Game = game_id_to_game(game_idx);
   
    %{ print(f"{ids.updated_game.player_x=} {ids.updated_game.state_x=} {ids.updated_game.last_mover=}") 
    %}
    
    assert updated_game.player_x = 123;
    assert updated_game.state_x = 33;

    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(124) %}
    join_game(game_idx);
    make_move(game_idx, 1);
    let updated_game : Game = game_id_to_game(game_idx);
   

   %{ print(f"{ids.updated_game.player_o=} {ids.updated_game.state_o=} {ids.updated_game.last_mover=}") 
    %}

    assert updated_game.player_o = 124;
    assert updated_game.state_o = 1;

    %{ stop_prank_callable() %}
    return ();
}
