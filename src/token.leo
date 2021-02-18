circuit Token {
    prg_debit_id: [u8; 48],
    prg_credit_id: [u8; 48],

    function new(debit_id: [u8; 48], credit_id: [u8; 48]) -> Self {
        return Self {
            prg_debit_id: debit_id,
            prg_credit_id: credit_id,
        }
    }

    function debit(self, 
                   input: circuit,
                   token_id: u8, 
                   value_balance_old: u8,
                   payload: [u8; 32],
                   debit_id: [u8; 48],
                   credit_id: [u8; 48],
                   global_index: u32,
                   ) -> (u8, u8) {
        // 1. Check token ids match
        let payload_token_id: u8 = payload[0];
        let condition1 = token_id == payload_token_id;

        // 2. Check record death is token_debit
        let condition2 = debit_id == self.prg_debit_id;

        // 3. Check record birth is token_credit
        let condition3 = credit_id == self.prg_credit_id;

        // 4. Handle old_record_0 new token case
        let is_zero = value_balance_old == 0;
        let condition4 = if global_index == 0 ? is_zero : true;

        // 5. Add payload value to register value balance
        let value_balance_payload: u8 = payload[1];
        let value_balance_new = value_balance_old + value_balance_payload;
        
        // 6. Check that no money is lost
        let condition5 = value_balance_new >= value_balance_old;
        
        // 7. Debit the funds if checks pass
        let passed = condition1 && condition2 && condition3 && condition4 && condition5;

        // if passed {
        //     return (token_id, value_balance_new)
        // } else {
        //     return (token_id, value_balance_old)
        // }    
        let vb_final = if passed? value_balance_new : value_balance_old;
        return (token_id, vb_final)
    }

    function credit(self,
                   token_id: u8, 
                   value_balance_old: u8,
                   payload: [u8; 32],
                   credit_id: [u8; 48],
                   global_index: u32,
                   ) -> (u8, u8) {
        // 1. Check token ids match
        let payload_token_id: u8 = payload[0];
        let condition1 = token_id == payload_token_id;

        // 2. Check record birth is token_credit
        let condition2 = credit_id == self.prg_credit_id;

        // 3. Subtract payload value form register value balance
        let value_balance_payload: u8 = payload[1];
        let mut value_balance_new = value_balance_old - value_balance_payload;
        
        // 4. Check that no money is created
        let condition3 = value_balance_new <= value_balance_old;
        
        // 5. Handle new_record_1 value is conserved case
        let is_zero = value_balance_new == 0;
        let condition4 = if global_index == 3 ? is_zero : true;

        // 6. Credit the funds if checks pass
        let passed = condition1 && condition2 && condition3 && condition4;

        // if passed {
        //     return (token_id, value_balance_new)
        // } else {
        //     return (token_id, value_balance_old)
        // }       
        let vb_final = if passed? value_balance_new : value_balance_old;
        return (token_id, vb_final)  
    }
}