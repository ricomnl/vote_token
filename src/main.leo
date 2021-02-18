import token.Token;

function main(input) -> (u8, u8) {
    let token_id: u8 = input.registers.token_id;
    let value_balance_old: u8 = input.registers.value_balance;
    let payload: [u8; 32] = input.record.payload;
    let debit_id: [u8; 48] = input.record.death_program_id;
    let credit_id: [u8; 48] = input.record.birth_program_id;
    let global_index: u32 = input.state.leaf_index;

    const token = Token::new(debit_id, credit_id);

    let (id_d, vb_d): (u8, u8) = token.debit(token_id,
                                            value_balance_old,    
                                            payload,
                                            debit_id,
                                            credit_id,
                                            global_index);

    console.log("debit: {}", (id_d, vb_d));

    // let (id_c, vb_c): (u8, u8) = token.credit(token_id,
    //                                             value_balance_old,    
    //                                             payload,
    //                                             credit_id,
    //                                             global_index);

    // console.log("credit: {}", (id_c, vb_c));

    return (id_d, vb_d)
    // return (id_c, vb_c)
}

@test(debit)
function test_token_create(input) {
    let debit_id: [u8; 48] = input.record.death_program_id;
    let credit_id: [u8; 48] = input.record.birth_program_id;
    let token = Token::new(debit_id, credit_id);

    console.assert(token.prg_debit_id == debit_id);
    console.assert(token.prg_credit_id == credit_id);
}

@test(debit)
function test_token_debit(input) {
    let token_id: u8 = input.registers.token_id;
    let value_balance_old: u8 = input.registers.value_balance;
    let payload: [u8; 32] = input.record.payload;
    let debit_id: [u8; 48] = input.record.death_program_id;
    let credit_id: [u8; 48] = input.record.birth_program_id;
    let global_index: u32 = input.state.leaf_index;

    let token = Token::new(debit_id, credit_id);

    let (id_t, vb_t) = token.debit(input, token_id,
                                    value_balance_old,    
                                    payload,
                                    debit_id,
                                    credit_id,
                                    global_index);

    console.assert(id_t == token_id);
    console.assert(vb_t == value_balance_old + payload[1]);   
}

@test(credit)
function test_token_credit(input) {
    let token_id: u8 = input.registers.token_id;
    let value_balance_old: u8 = input.registers.value_balance;
    let payload: [u8; 32] = input.record.payload;
    let debit_id: [u8; 48] = input.record.death_program_id;
    let credit_id: [u8; 48] = input.record.birth_program_id;
    let global_index: u32 = input.state.leaf_index;

    let token = Token::new(debit_id, credit_id);

    let (id_t, vb_t) = token.credit(token_id,
                                    value_balance_old,    
                                    payload,
                                    credit_id,
                                    global_index);

    console.assert(id_t == token_id);
    console.assert(vb_t == value_balance_old - payload[1]);   
}