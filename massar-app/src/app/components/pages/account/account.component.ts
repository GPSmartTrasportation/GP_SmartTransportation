import { Component } from '@angular/core';
import { DataService } from '../../../data/data.service';

@Component({
  selector: 'app-account',
  templateUrl: './account.component.html',
  styleUrls: ['./account.component.scss']
})
export class AccountComponent {
  promoCode = '';
  promoMessage = '';
  promoSuccess = false;
  topUpAmount = 100;
  topUpSuccess = false;
  topUpOptions = [50, 100, 200, 500];

  constructor(public data: DataService) {}

  get initials(): string {
    return this.data.currentUser.name
      .split(' ')
      .map((n: string) => n[0])
      .join('');
  }

  get completedRides(): number {
    return this.data.rideHistory.filter(r => r.status === 'completed').length;
  }

  get totalSpent(): string {
    return this.data.rideHistory
      .filter(r => r.amount > 0)
      .reduce((a, r) => a + r.amount, 0)
      .toFixed(0);
  }

  get totalDistance(): string {
    return this.data.rideHistory
      .filter(r => r.distance > 0)
      .reduce((a, r) => a + r.distance, 0)
      .toFixed(1);
  }

  get walletBalance(): string {
    return this.data.currentUser.walletBalance.toFixed(2);
  }

  setTopUp(amount: number) {
    this.topUpAmount = amount;
  }

  isTopUpSelected(amount: number): boolean {
    return this.topUpAmount === amount;
  }

  applyPromo() {
    if (!this.promoCode.trim()) return;
    const result = this.data.validatePromo(this.promoCode.trim());
    if (result.valid) {
      const disc = result.type === 'percent'
        ? result.discount + '% off'
        : 'EGP ' + result.discount + ' off';
      this.promoMessage = '✅ Code applied! ' + disc + ' your next ride.';
      this.promoSuccess = true;
    } else {
      this.promoMessage = '❌ Invalid promo code. Please try again.';
      this.promoSuccess = false;
    }
  }

  topUp() {
    this.data.currentUser.walletBalance += this.topUpAmount;
    this.topUpSuccess = true;
    setTimeout(() => (this.topUpSuccess = false), 3000);
  }
}
