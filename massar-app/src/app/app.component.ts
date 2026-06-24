import { Component } from '@angular/core';
import { Zone } from './models/models';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  activeTab: 'book' | 'trips' | 'account' = 'book';
  currentStep = 'booking';
  mapPickup: Zone | null = null;
  mapDropoff: Zone | null = null;

  get showMap(): boolean {
    return this.activeTab === 'book';
  }
}
