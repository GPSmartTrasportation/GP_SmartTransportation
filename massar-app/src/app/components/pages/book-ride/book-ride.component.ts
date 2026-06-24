import { Component, OnInit, Output, EventEmitter } from '@angular/core';
import { DataService } from '../../../data/data.service';
import { FareService } from '../../../services/fare.service';
import { BookingForm, Zone, VehicleType, FareEstimate, AppStep } from '../../../models/models';

@Component({
  selector: 'app-book-ride',
  templateUrl: './book-ride.component.html',
  styleUrls: ['./book-ride.component.scss']
})
export class BookRideComponent implements OnInit {
  @Output() pickupChanged = new EventEmitter<Zone | null>();
  @Output() dropoffChanged = new EventEmitter<Zone | null>();
  @Output() stepChanged = new EventEmitter<AppStep>();

  step: AppStep = 'booking';
  isCalculating = false;
  isSearching = false;

  zones: Zone[] = [];
  vehicleTypes: VehicleType[] = [];

  form: BookingForm = {
    pickupZoneId: null,
    dropoffZoneId: null,
    tripType: 'passenger',
    passengerCount: 1,
    cargoType: '',
    cargoWeight: null,
    receiverName: '',
    receiverPhone: '',
    pickupTime: 'now',
    scheduledDate: '',
    scheduledTime: '',
    vehicleTypeId: null,
    promoCode: ''
  };

  fareEstimate: FareEstimate | null = null;
  promoApplied = false;
  promoError = '';
  selectedPayment: 'wallet' | 'cash' | 'card' = 'wallet';
  userRating = 0;
  hoverRating = 0;
  ratingComment = '';
  ratingSubmitted = false;

  rideRef = '';

  readonly cargoTypes = ['Electronics', 'Furniture', 'Food & Groceries', 'Documents', 'Building Materials', 'Other'];
  readonly passengerCounts = [1, 2, 3, 4, 5, 6];

  constructor(
    public data: DataService,
    private fare: FareService
  ) {}

  ngOnInit() {
    this.zones = this.data.zones;
    this.vehicleTypes = this.data.vehicleTypes;
    this.form.vehicleTypeId = this.vehicleTypes[0].id;
  }

  get pickupZone(): Zone | null {
    return this.form.pickupZoneId ? this.data.getZoneById(this.form.pickupZoneId) ?? null : null;
  }

  get dropoffZone(): Zone | null {
    return this.form.dropoffZoneId ? this.data.getZoneById(this.form.dropoffZoneId) ?? null : null;
  }

  get filteredDropoffZones(): Zone[] {
    return this.zones.filter(z => z.id !== this.form.pickupZoneId);
  }

  get filteredPickupZones(): Zone[] {
    return this.zones.filter(z => z.id !== this.form.dropoffZoneId);
  }

  get selectedVehicle(): VehicleType | undefined {
    return this.vehicleTypes.find(v => v.id === this.form.vehicleTypeId);
  }

  get canCalculate(): boolean {
    return !!(
      this.form.pickupZoneId &&
      this.form.dropoffZoneId &&
      this.form.vehicleTypeId
    );
  }

  onPickupChange(event: Event) {
    const val = +(event.target as HTMLSelectElement).value;
    this.form.pickupZoneId = val || null;
    this.pickupChanged.emit(this.pickupZone);
    if (this.form.dropoffZoneId === val) this.form.dropoffZoneId = null;
  }

  onDropoffChange(event: Event) {
    const val = +(event.target as HTMLSelectElement).value;
    this.form.dropoffZoneId = val || null;
    this.dropoffChanged.emit(this.dropoffZone);
  }

  swapLocations() {
    const tmp = this.form.pickupZoneId;
    this.form.pickupZoneId = this.form.dropoffZoneId;
    this.form.dropoffZoneId = tmp;
    this.pickupChanged.emit(this.pickupZone);
    this.dropoffChanged.emit(this.dropoffZone);
  }

  onVehicleSelect(id: number) {
    this.form.vehicleTypeId = id;
  }

  calculateFare() {
    if (!this.canCalculate) return;
    this.isCalculating = true;
    setTimeout(() => {
      this.fareEstimate = this.fare.calculate({
        pickupZoneId: this.form.pickupZoneId!,
        dropoffZoneId: this.form.dropoffZoneId!,
        vehicleTypeId: this.form.vehicleTypeId!,
        tripType: this.form.tripType,
        promoCode: this.form.promoCode
      });
      this.isCalculating = false;
      this.step = 'fare';
      this.stepChanged.emit(this.step);
    }, 1500);
  }

  confirmRide() {
    this.step = 'searching';
    this.stepChanged.emit(this.step);
    this.rideRef = '#' + (1040 + Math.floor(Math.random() * 100));
    setTimeout(() => {
      this.step = 'driver_on_way';
      this.stepChanged.emit(this.step);
      setTimeout(() => {
        this.step = 'completed';
        this.stepChanged.emit(this.step);
      }, 6000);
    }, 5000);
  }

  cancelRide() {
    this.resetToBooking();
  }

  resetToBooking() {
    this.step = 'booking';
    this.stepChanged.emit(this.step);
    this.fareEstimate = null;
    this.ratingSubmitted = false;
    this.userRating = 0;
  }

  submitRating() {
    if (this.userRating === 0) return;
    this.ratingSubmitted = true;
    setTimeout(() => this.resetToBooking(), 2000);
  }

  setRating(star: number) { this.userRating = star; }
  onStarHover(star: number) { this.hoverRating = star; }
  onStarLeave() { this.hoverRating = 0; }

  get displayRating(): number {
    return this.hoverRating || this.userRating;
  }

  get walletAfterPayment(): number {
    return this.data.currentUser.walletBalance - (this.fareEstimate?.total ?? 0);
  }
}
