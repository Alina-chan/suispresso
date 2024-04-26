// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Module: suispress membership management
module suispresso::membership {
  // === Imports ===
  use suispresso::config::{ManagerCap};
  use std::string::{String};

  // === Structs === 

  // Customer loyalty membership card
  public struct MembershipCard has key {
    // unique identifier
    id: UID,
    // accumulation of points
    points: u64,
    // the owner's address
    owner: address,
    // name of customer
    name: String,
    // whether the card is activated
    active: bool,
    // past orders
    orders: vector<ID>,
  }

  // === Errors ===
  const ECannotResetPoints: u64 = 0;

  // === Constants ===
  const MIN_GIFT_POINTS: u64 = 10;

  // === Public Functions === 

  // Issue a new MembershipCard for a user 
  public fun new(
    _: &ManagerCap, points: u64, owner: address, name: String, ctx: &mut TxContext
  ) {
    let membership_card = MembershipCard {
      id: object::new(ctx),
      points,
      owner,
      name,
      active: true,
      orders: vector::empty()
    };

    transfer::transfer(membership_card, owner);
  }

  // === Accessors ===

  public fun get_points(self: &MembershipCard): u64 {
    self.points
  }

  // === Update Functions ===

  // Increments MembershipCard points with given points
  public(package) fun add_points(self: &mut MembershipCard, new_points: u64) {
    self.points =  self.points + new_points
  }

  // Deducts points for current coffee
  public(package) fun deduct_points(self: &mut MembershipCard) {
    // Make sure that current points in MembershipCard are more or equal to 
    // the minimum required for getting a free coffee
    assert!(self.points >= MIN_GIFT_POINTS, ECannotResetPoints);

    self.points = self.points - MIN_GIFT_POINTS;
  }
}