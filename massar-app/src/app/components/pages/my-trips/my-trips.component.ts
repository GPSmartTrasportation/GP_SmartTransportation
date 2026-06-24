import { Component } from '@angular/core';
import { DataService } from '../../../data/data.service';
import { Ride } from '../../../models/models';

@Component({
  selector: 'app-my-trips',
  templateUrl: './my-trips.component.html',
  styleUrls: ['./my-trips.component.scss']
})
export class MyTripsComponent {
  selectedRide: Ride | null = null;
  filterStatus: 'all' | 'completed' | 'cancelled' | 'in_progress' = 'all';

  constructor(public data: DataService) {}

  get filteredRides(): Ride[] {
    if (this.filterStatus === 'all') return this.data.rideHistory;
    return this.data.rideHistory.filter(r => r.status === this.filterStatus);
  }

  statusLabel(s: string) {
    if (s === 'completed') return 'Completed';
    if (s === 'cancelled') return 'Cancelled';
    return 'In Progress';
  }

  statusClass(s: string) {
    if (s === 'completed') return 'badge-success';
    if (s === 'cancelled') return 'badge-danger';
    return 'badge-info';
  }
}
