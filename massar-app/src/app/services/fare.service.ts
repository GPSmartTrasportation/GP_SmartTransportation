import { Injectable } from '@angular/core';
import { FareEstimate } from '../models/models';
import { DataService } from '../data/data.service';

@Injectable({ providedIn: 'root' })
export class FareService {

  private readonly BASE_FARE = 20;
  private readonly RATE_PER_KM = 7;

  constructor(private data: DataService) {}

  calculate(params: {
    pickupZoneId: number;
    dropoffZoneId: number;
    vehicleTypeId: number;
    tripType: 'passenger' | 'cargo';
    promoCode: string;
  }): FareEstimate {
    const pickup = this.data.getZoneById(params.pickupZoneId)!;
    const dropoff = this.data.getZoneById(params.dropoffZoneId)!;
    const vehicle = this.data.getVehicleTypeById(params.vehicleTypeId)!;

    const distance = this.data.estimateDistance(pickup, dropoff);
    const duration = Math.round(distance * 2.8 + 5); // avg city speed

    const multiplier = params.tripType === 'cargo'
      ? vehicle.baseMultiplier * 1.3
      : vehicle.baseMultiplier;

    const distanceFare = distance * this.RATE_PER_KM;
    const subtotal = (this.BASE_FARE + distanceFare) * multiplier;

    // Promo discount
    let promoDiscount = 0;
    const promo = this.data.validatePromo(params.promoCode);
    if (promo.valid) {
      promoDiscount = promo.type === 'percent'
        ? subtotal * (promo.discount / 100)
        : promo.discount;
    }

    // Subscription discount
    let subscriptionDiscount = 0;
    const sub = this.data.currentUser.subscription;
    if (sub && sub.status === 'active') {
      subscriptionDiscount = (subtotal - promoDiscount) * (sub.discountPercent / 100);
    }

    const total = Math.max(subtotal - promoDiscount - subscriptionDiscount, 10);

    const driver = this.data.getRandomDriver(params.vehicleTypeId);

    return {
      distance,
      duration,
      baseFare: this.BASE_FARE,
      distanceFare: Math.round(distanceFare * 100) / 100,
      vehicleMultiplier: Math.round(multiplier * 10) / 10,
      subtotal: Math.round(subtotal * 100) / 100,
      promoDiscount: Math.round(promoDiscount * 100) / 100,
      subscriptionDiscount: Math.round(subscriptionDiscount * 100) / 100,
      total: Math.round(total * 100) / 100,
      promoCode: promo.valid ? params.promoCode.toUpperCase() : undefined,
      suggestedDriver: driver,
    };
  }
}
