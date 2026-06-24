// ============================================
// MASSAR - Data Models
// ============================================

export interface Zone {
  id: number;
  name: string;
  cityId: number;
  cityName: string;
  governorateName: string;
  lat: number;
  lng: number;
}

export interface VehicleType {
  id: number;
  name: string;
  icon: string;
  description: string;
  baseMultiplier: number;
  maxPassengers: number;
}

export interface Driver {
  id: number;
  name: string;
  rating: number;
  totalRatings: number;
  vehicleBrand: string;
  vehicleModel: string;
  vehicleType: string;
  licensePlate: string;
  avatar: string;
  arrivalMinutes: number;
}

export interface FareEstimate {
  distance: number;
  duration: number;
  baseFare: number;
  distanceFare: number;
  vehicleMultiplier: number;
  subtotal: number;
  promoDiscount: number;
  subscriptionDiscount: number;
  total: number;
  promoCode?: string;
  suggestedDriver: Driver;
}

export interface Ride {
  id: number;
  rideRef: string;
  date: string;
  status: 'completed' | 'cancelled' | 'in_progress';
  pickupZone: string;
  dropoffZone: string;
  amount: number;
  paymentType: string;
  vehicleType: string;
  driverName: string;
  distance: number;
  duration: number;
}

export interface User {
  id: number;
  name: string;
  phone: string;
  email: string;
  walletBalance: number;
  subscription: Subscription | null;
}

export interface Subscription {
  planName: string;
  status: 'active' | 'expired';
  discountPercent: number;
  expiryDate: string;
}

export interface BookingForm {
  pickupZoneId: number | null;
  dropoffZoneId: number | null;
  tripType: 'passenger' | 'cargo';
  passengerCount: number;
  cargoType: string;
  cargoWeight: number | null;
  receiverName: string;
  receiverPhone: string;
  pickupTime: 'now' | 'scheduled';
  scheduledDate: string;
  scheduledTime: string;
  vehicleTypeId: number | null;
  promoCode: string;
}

export type AppStep =
  | 'booking'
  | 'fare'
  | 'searching'
  | 'driver_on_way'
  | 'completed';
