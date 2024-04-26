// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Module: suispresso configuration and administrative functions 
module suispresso::config {
  // === Structs ===

  // Manager capability for manager only related actions 
  public struct ManagerCap has key, store {
    id: UID,
  }

  fun init(ctx: &mut TxContext) {
    let admin_cap = ManagerCap {
      id: object::new(ctx)
    };

    transfer::public_transfer(admin_cap, tx_context::sender(ctx));
  }
}