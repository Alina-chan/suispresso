// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Module: suispresso
module suispresso::suispresso {
  // === Imports ===
  use sui::coin::{Self, Coin};
  use sui::sui::{SUI};
  use sui::balance::{Self, Balance};
  use suispresso::config::{ManagerCap};
  use suispresso::membership::{MembershipCard};
  use std::string::{String};
  use sui::dynamic_field;
  use sui::dynamic_object_field;

  // === Structs ===

  // Main struct where we keep the earnings of our shop
  public struct CashRegister has key {
    id: UID,
    balance: Balance<SUI>,
  }

  // Simple coffee struct
  public struct Coffee has key, store {
    // unique identifier for each coffee
    id: UID,
  }

  // Struct for resembling a straw
  public struct Straw has key, store {
    id: UID,
    straw_type: String,
  }

  // === Errrors ===
  const ENotEnoughPoints: u64 = 0;

  // === Constants ===
  const MIN_GIFT_POINTS: u64 = 10;
  const POINTS_PER_COFFEE: u64 = 1;

  // Creates one unique CashRegister object for our shop 
  // upon publishing the contract
  fun init(ctx: &mut TxContext) {
    transfer::share_object(
      CashRegister {
        id: object::new(ctx),
        balance: balance::zero<SUI>()
      }
    );
  }

  // === Public Functions ===

  // Buy a coffee with SUI
  public fun buy_coffee(
    payment: Coin<SUI>, registry: &mut CashRegister, ctx: &mut TxContext
  ): Coffee {
    // Convert to balance and add to cash register 
    let payment_balance = payment.into_balance<SUI>();
    registry.balance.join(payment_balance);

    // Brew and return a coffee
    Coffee {
      id: object::new(ctx)
    }
  }

  // Buy coffee as member with SUI
  public fun member_buy_coffee(
    card: &mut MembershipCard, 
    payment: Coin<SUI>, 
    registry: &mut CashRegister, 
    ctx: &mut TxContext
  ): Coffee {
    // Update membership card with 1 point
    card.add_points(POINTS_PER_COFFEE);

    // Brew and give coffee
    buy_coffee(payment, registry, ctx)
  }

  // Get a free coffee if membership card has more than 10 points
  public fun claim_free_coffee(
    card: &mut MembershipCard, ctx: &mut TxContext
  ): Coffee {
    assert!(card.get_points() >= MIN_GIFT_POINTS, ENotEnoughPoints);
    card.deduct_points();

    Coffee {
      id: object::new(ctx)
    }
  }

  // Add sugar to Coffee as dynamic field 
  public fun add_sugar(coffee: &mut Coffee, quantity: u64) {
    dynamic_field::add(&mut coffee.id, b"sugar", quantity);
  }

  // Add a straw to Coffee as a dynamic object field
  public fun add_straw(coffee: &mut Coffee, straw_type: String, ctx: &mut TxContext) {
    dynamic_object_field::add(&mut coffee.id, b"straw", Straw {
      id: object::new(ctx),
      straw_type
    });
  }

  // === Manager Functions ===

  // Manager can withdraw the money out of the CashRegister
  public fun withdraw_profits(
    _: &ManagerCap, registry: &mut CashRegister, ctx: &mut TxContext
  ): Coin<SUI> {
    // Withdraw all balance
    let registry_balance = registry.balance.withdraw_all<SUI>();

    // Wrap balance into a Coin to make it transferable
    coin::from_balance<SUI>(registry_balance, ctx)
  }
}
