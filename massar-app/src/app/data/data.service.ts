import { Injectable } from '@angular/core';
import { Zone, VehicleType, Driver, Ride, User } from '../models/models';

@Injectable({ providedIn: 'root' })
export class DataService {

  readonly currentUser: User = {
    id: 1,
    name: 'Ahmed Mohamed',
    phone: '+20 100 234 5678',
    email: 'ahmed.mohamed@email.com',
    walletBalance: 150.00,
    subscription: {
      planName: 'Gold',
      status: 'active',
      discountPercent: 10,
      expiryDate: '2026-08-31'
    }
  };

  readonly zones: Zone[] = [
    // Nasr City — Cairo
    { id: 1,  name: 'Zone 1',         cityId: 1,  cityName: 'Nasr City',     governorateName: 'Cairo',     lat: 30.0580, lng: 31.3300 },
    { id: 2,  name: 'Zone 7',         cityId: 1,  cityName: 'Nasr City',     governorateName: 'Cairo',     lat: 30.0650, lng: 31.3420 },
    { id: 3,  name: 'Zone 10',        cityId: 1,  cityName: 'Nasr City',     governorateName: 'Cairo',     lat: 30.0720, lng: 31.3480 },
    { id: 4,  name: 'Makram Ebeid',   cityId: 1,  cityName: 'Nasr City',     governorateName: 'Cairo',     lat: 30.0680, lng: 31.3550 },
    { id: 5,  name: 'Abbas El Akkad', cityId: 1,  cityName: 'Nasr City',     governorateName: 'Cairo',     lat: 30.0620, lng: 31.3380 },
    // Maadi — Cairo
    { id: 6,  name: 'New Maadi',      cityId: 2,  cityName: 'Maadi',         governorateName: 'Cairo',     lat: 29.9720, lng: 31.2680 },
    { id: 7,  name: 'Old Maadi',      cityId: 2,  cityName: 'Maadi',         governorateName: 'Cairo',     lat: 29.9580, lng: 31.2580 },
    { id: 8,  name: 'Degla Maadi',    cityId: 2,  cityName: 'Maadi',         governorateName: 'Cairo',     lat: 29.9520, lng: 31.2520 },
    { id: 9,  name: 'Zahraa El Maadi',cityId: 2,  cityName: 'Maadi',         governorateName: 'Cairo',     lat: 29.9650, lng: 31.2750 },
    // New Cairo — Cairo
    { id: 10, name: 'Fifth Settlement', cityId: 3, cityName: 'New Cairo',   governorateName: 'Cairo',     lat: 30.0150, lng: 31.4950 },
    { id: 11, name: 'First Settlement', cityId: 3, cityName: 'New Cairo',   governorateName: 'Cairo',     lat: 30.0280, lng: 31.4780 },
    { id: 12, name: 'Rehab',          cityId: 3,  cityName: 'New Cairo',     governorateName: 'Cairo',     lat: 30.0588, lng: 31.4944 },
    { id: 13, name: 'Madinaty',       cityId: 3,  cityName: 'New Cairo',     governorateName: 'Cairo',     lat: 30.0920, lng: 31.6320 },
    // Heliopolis — Cairo
    { id: 14, name: 'Korba',          cityId: 4,  cityName: 'Heliopolis',    governorateName: 'Cairo',     lat: 30.0880, lng: 31.3280 },
    { id: 15, name: 'Merryland',      cityId: 4,  cityName: 'Heliopolis',    governorateName: 'Cairo',     lat: 30.0920, lng: 31.3180 },
    { id: 16, name: 'El Golf',        cityId: 4,  cityName: 'Heliopolis',    governorateName: 'Cairo',     lat: 30.0850, lng: 31.3350 },
    { id: 17, name: 'Roxy',           cityId: 4,  cityName: 'Heliopolis',    governorateName: 'Cairo',     lat: 30.0780, lng: 31.3100 },
    // Downtown — Cairo
    { id: 18, name: 'Tahrir',         cityId: 5,  cityName: 'Downtown',      governorateName: 'Cairo',     lat: 30.0444, lng: 31.2357 },
    { id: 19, name: 'Ataba',          cityId: 5,  cityName: 'Downtown',      governorateName: 'Cairo',     lat: 30.0520, lng: 31.2420 },
    { id: 20, name: 'Bab El Louk',    cityId: 5,  cityName: 'Downtown',      governorateName: 'Cairo',     lat: 30.0400, lng: 31.2380 },
    // Shubra — Cairo
    { id: 21, name: 'Shubra El Kheima', cityId: 6, cityName: 'Shubra',       governorateName: 'Cairo',     lat: 30.1280, lng: 31.2480 },
    { id: 22, name: 'Rod El Farag',   cityId: 6,  cityName: 'Shubra',        governorateName: 'Cairo',     lat: 30.1050, lng: 31.2520 },
    { id: 23, name: 'El Mazallat',    cityId: 6,  cityName: 'Shubra',        governorateName: 'Cairo',     lat: 30.0985, lng: 31.2434 },
    // Dokki — Giza
    { id: 24, name: 'Dokki Center',   cityId: 7,  cityName: 'Dokki',         governorateName: 'Giza',      lat: 30.0419, lng: 31.2086 },
    { id: 25, name: 'Agouza',         cityId: 7,  cityName: 'Dokki',         governorateName: 'Giza',      lat: 30.0520, lng: 31.2150 },
    { id: 26, name: 'Lebanon Square', cityId: 7,  cityName: 'Dokki',         governorateName: 'Giza',      lat: 30.0480, lng: 31.2020 },
    { id: 27, name: 'Gameat El Dewal',cityId: 7,  cityName: 'Dokki',         governorateName: 'Giza',      lat: 30.0380, lng: 31.1980 },
    { id: 28, name: 'Cairo Univ St',  cityId: 7,  cityName: 'Dokki',         governorateName: 'Giza',      lat: 30.0280, lng: 31.2100 },
    { id: 29, name: 'Sphinx',         cityId: 7,  cityName: 'Dokki',         governorateName: 'Giza',      lat: 30.0350, lng: 31.2050 },
    // 6th October — Giza
    { id: 30, name: 'District 1',     cityId: 9,  cityName: '6th October',   governorateName: 'Giza',      lat: 29.9380, lng: 30.9300 },
    { id: 31, name: 'District 7',     cityId: 9,  cityName: '6th October',   governorateName: 'Giza',      lat: 29.9280, lng: 30.9180 },
    { id: 32, name: 'Industrial Zone',cityId: 9,  cityName: '6th October',   governorateName: 'Giza',      lat: 29.9200, lng: 30.9400 },
    { id: 33, name: 'Dreamland',      cityId: 9,  cityName: '6th October',   governorateName: 'Giza',      lat: 29.9450, lng: 30.9050 },
    // Sheikh Zayed — Giza
    { id: 34, name: 'District 1',     cityId: 10, cityName: 'Sheikh Zayed',  governorateName: 'Giza',      lat: 30.0320, lng: 30.9820 },
    { id: 35, name: 'District 5',     cityId: 10, cityName: 'Sheikh Zayed',  governorateName: 'Giza',      lat: 30.0250, lng: 30.9700 },
    { id: 36, name: 'Beverly Hills',  cityId: 10, cityName: 'Sheikh Zayed',  governorateName: 'Giza',      lat: 30.0180, lng: 30.9880 },
    // Sidi Gaber — Alexandria
    { id: 37, name: 'Sidi Gaber Bahari', cityId: 11, cityName: 'Sidi Gaber', governorateName: 'Alexandria', lat: 31.2180, lng: 29.9520 },
    { id: 38, name: 'Kafr Abdo',      cityId: 11, cityName: 'Sidi Gaber',    governorateName: 'Alexandria', lat: 31.2120, lng: 29.9580 },
    { id: 39, name: 'Cleopatra',      cityId: 11, cityName: 'Sidi Gaber',    governorateName: 'Alexandria', lat: 31.2200, lng: 29.9480 },
    // Smouha — Alexandria
    { id: 40, name: 'Smouha Center',  cityId: 12, cityName: 'Smouha',        governorateName: 'Alexandria', lat: 31.2150, lng: 29.9600 },
    { id: 41, name: 'Victoria',       cityId: 12, cityName: 'Smouha',        governorateName: 'Alexandria', lat: 31.2100, lng: 29.9650 },
    { id: 42, name: 'San Stefano',    cityId: 12, cityName: 'Smouha',        governorateName: 'Alexandria', lat: 31.2180, lng: 29.9680 },
    // Montaza — Alexandria
    { id: 43, name: 'Montaza Park',   cityId: 13, cityName: 'Montaza',       governorateName: 'Alexandria', lat: 31.2850, lng: 30.0200 },
    { id: 44, name: 'El Mamoura',     cityId: 13, cityName: 'Montaza',       governorateName: 'Alexandria', lat: 31.2780, lng: 30.0150 },
    { id: 45, name: 'El Asafra',      cityId: 13, cityName: 'Montaza',       governorateName: 'Alexandria', lat: 31.2720, lng: 30.0280 },
    { id: 46, name: 'Sidi Bishr',     cityId: 13, cityName: 'Montaza',       governorateName: 'Alexandria', lat: 31.2680, lng: 30.0100 },
    // Mansoura — Dakahlia
    { id: 47, name: 'Mogmaa Elmahakem', cityId: 14, cityName: 'Mansoura',    governorateName: 'Dakahlia',  lat: 31.0420, lng: 31.3820 },
    { id: 48, name: 'Toreel',         cityId: 14, cityName: 'Mansoura',      governorateName: 'Dakahlia',  lat: 31.0380, lng: 31.3750 },
    { id: 49, name: 'Gehan',          cityId: 14, cityName: 'Mansoura',      governorateName: 'Dakahlia',  lat: 31.0450, lng: 31.3700 },
    { id: 50, name: 'University Area',cityId: 14, cityName: 'Mansoura',      governorateName: 'Dakahlia',  lat: 31.0409, lng: 31.3785 },
    // Talkha — Dakahlia
    { id: 51, name: 'Talkha Center',  cityId: 15, cityName: 'Talkha',        governorateName: 'Dakahlia',  lat: 31.0550, lng: 31.3700 },
    { id: 52, name: 'Kafr El Badamas',cityId: 15, cityName: 'Talkha',        governorateName: 'Dakahlia',  lat: 31.0620, lng: 31.3650 },
    // Mit Ghamr — Dakahlia
    { id: 53, name: 'Mit Ghamr Center', cityId: 16, cityName: 'Mit Ghamr', governorateName: 'Dakahlia',  lat: 30.7167, lng: 31.2500 },
    { id: 54, name: 'Kafr Shokr',     cityId: 16, cityName: 'Mit Ghamr',    governorateName: 'Dakahlia',  lat: 30.7080, lng: 31.2580 },
    // Shibin El Kom — Monufia
    { id: 55, name: 'Shibin Center',  cityId: 17, cityName: 'Shibin El Kom', governorateName: 'Monufia', lat: 30.5544, lng: 31.0094 },
    { id: 56, name: 'Kafr El Bagour', cityId: 17, cityName: 'Shibin El Kom', governorateName: 'Monufia', lat: 30.5480, lng: 31.0180 },
    // Sadat City — Monufia
    { id: 57, name: 'Residential 1',  cityId: 18, cityName: 'Sadat City',    governorateName: 'Monufia',   lat: 30.4167, lng: 30.5167 },
    { id: 58, name: 'Industrial Zone',cityId: 18, cityName: 'Sadat City',    governorateName: 'Monufia',   lat: 30.4080, lng: 30.5250 },
    // Menouf — Monufia
    { id: 59, name: 'Menouf Center',  cityId: 19, cityName: 'Menouf',        governorateName: 'Monufia',   lat: 30.4653, lng: 30.9314 },
    { id: 60, name: 'Sers El Layan',  cityId: 19, cityName: 'Menouf',        governorateName: 'Monufia',   lat: 30.4580, lng: 30.9400 },
  ];

  readonly governorates: string[] = ['Cairo', 'Giza', 'Alexandria', 'Dakahlia', 'Monufia'];

  readonly vehicleTypes: VehicleType[] = [
    { id: 1, name: 'Economy',     icon: '🚗', description: 'Affordable everyday rides',        baseMultiplier: 1.0, maxPassengers: 4 },
    { id: 2, name: 'Comfort',     icon: '🚙', description: 'More comfort, top-rated drivers',  baseMultiplier: 1.2, maxPassengers: 4 },
    { id: 3, name: 'SUV',         icon: '🚐', description: 'Spacious rides for groups',        baseMultiplier: 1.5, maxPassengers: 6 },
    { id: 4, name: 'Pickup Truck',icon: '🛻', description: 'Light cargo & deliveries',         baseMultiplier: 1.6, maxPassengers: 2 },
    { id: 5, name: 'Half Truck',  icon: '🚛', description: 'Heavy cargo transport',            baseMultiplier: 2.0, maxPassengers: 2 },
  ];

  readonly drivers: Driver[] = [
    { id: 1, name: 'Mohamed Ali',    rating: 4.8, totalRatings: 234, vehicleBrand: 'Toyota',  vehicleModel: 'Corolla',  vehicleType: 'Economy', licensePlate: 'ABC 1234', avatar: 'MA', arrivalMinutes: 4 },
    { id: 2, name: 'Khaled Hassan',  rating: 4.9, totalRatings: 512, vehicleBrand: 'Hyundai', vehicleModel: 'Elantra',  vehicleType: 'Economy', licensePlate: 'XYZ 5678', avatar: 'KH', arrivalMinutes: 3 },
    { id: 3, name: 'Tarek Mahmoud',  rating: 4.7, totalRatings: 189, vehicleBrand: 'Kia',     vehicleModel: 'K5',       vehicleType: 'Comfort', licensePlate: 'DEF 9012', avatar: 'TM', arrivalMinutes: 6 },
    { id: 4, name: 'Ahmed Sayed',    rating: 4.6, totalRatings: 97,  vehicleBrand: 'Toyota',  vehicleModel: 'Fortuner', vehicleType: 'SUV',     licensePlate: 'GHI 3456', avatar: 'AS', arrivalMinutes: 7 },
    { id: 5, name: 'Omar Ibrahim',   rating: 4.8, totalRatings: 321, vehicleBrand: 'Ford',    vehicleModel: 'Ranger',   vehicleType: 'Pickup Truck', licensePlate: 'JKL 7890', avatar: 'OI', arrivalMinutes: 9 },
  ];

  readonly promoCodes: { code: string; discount: number; type: 'percent' | 'flat' }[] = [
    { code: 'SUMMER20', discount: 20, type: 'percent' },
    { code: 'MASSAR10', discount: 10, type: 'flat' },
    { code: 'WELCOME15', discount: 15, type: 'percent' },
  ];

  readonly rideHistory: Ride[] = [
    { id: 1001, rideRef: '#1001', date: 'Jun 12, 2026', status: 'completed',   pickupZone: 'Nasr City - Zone 1',         dropoffZone: 'New Cairo - Fifth Settlement', amount: 72.50, paymentType: 'Wallet', vehicleType: 'Economy', driverName: 'Mohamed Ali',   distance: 8.5, duration: 22 },
    { id: 1002, rideRef: '#1002', date: 'Jun 10, 2026', status: 'completed',   pickupZone: 'Maadi - Old Maadi',          dropoffZone: 'Downtown - Tahrir',            amount: 45.00, paymentType: 'Cash',   vehicleType: 'Economy', driverName: 'Khaled Hassan', distance: 5.2, duration: 18 },
    { id: 1003, rideRef: '#1003', date: 'Jun 8, 2026',  status: 'cancelled',   pickupZone: 'Heliopolis - Korba',         dropoffZone: 'Dokki - Dokki Center',         amount: 0,     paymentType: '—',      vehicleType: 'Comfort', driverName: '—',             distance: 0,   duration: 0  },
    { id: 1004, rideRef: '#1004', date: 'Jun 5, 2026',  status: 'completed',   pickupZone: 'Downtown - Tahrir',          dropoffZone: 'Maadi - Degla Maadi',          amount: 55.00, paymentType: 'Card',   vehicleType: 'Comfort', driverName: 'Tarek Mahmoud', distance: 6.1, duration: 20 },
    { id: 1005, rideRef: '#1005', date: 'Jun 1, 2026',  status: 'completed',   pickupZone: 'New Cairo - Rehab',          dropoffZone: 'Nasr City - Makram Ebeid',     amount: 68.00, paymentType: 'Wallet', vehicleType: 'Economy', driverName: 'Mohamed Ali',   distance: 8.0, duration: 21 },
    { id: 1006, rideRef: '#1006', date: 'May 28, 2026', status: 'in_progress', pickupZone: 'New Cairo - Rehab',          dropoffZone: 'New Cairo - First Settlement', amount: 35.00, paymentType: 'Cash',   vehicleType: 'SUV',     driverName: 'Ahmed Sayed',   distance: 4.0, duration: 14 },
  ];

  getZoneLabel(zone: Zone): string {
    return `${zone.cityName} - ${zone.name}`;
  }

  getZoneById(id: number): Zone | undefined {
    return this.zones.find(z => z.id === id);
  }

  getVehicleTypeById(id: number): VehicleType | undefined {
    return this.vehicleTypes.find(v => v.id === id);
  }

  validatePromo(code: string): { valid: boolean; discount: number; type: 'percent' | 'flat' } {
    const promo = this.promoCodes.find(p => p.code.toUpperCase() === code.toUpperCase());
    if (promo) return { valid: true, discount: promo.discount, type: promo.type };
    return { valid: false, discount: 0, type: 'flat' };
  }

  /** Estimate distance (km) between two zones using Haversine */
  estimateDistance(from: Zone, to: Zone): number {
    const R = 6371;
    const dLat = ((to.lat - from.lat) * Math.PI) / 180;
    const dLng = ((to.lng - from.lng) * Math.PI) / 180;
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos((from.lat * Math.PI) / 180) *
      Math.cos((to.lat * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;
    const dist = R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return Math.max(1, Math.round(dist * 10) / 10);
  }

  getRandomDriver(vehicleTypeId: number): Driver {
    const vt = this.getVehicleTypeById(vehicleTypeId);
    const matching = this.drivers.filter(d =>
      vt ? d.vehicleType === vt.name : true
    );
    const pool = matching.length > 0 ? matching : this.drivers;
    return pool[Math.floor(Math.random() * pool.length)];
  }
}
