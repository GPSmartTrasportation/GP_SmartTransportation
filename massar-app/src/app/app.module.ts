import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';

import { AppComponent } from './app.component';
import { NavbarComponent } from './components/navbar/navbar.component';
import { MapPanelComponent } from './components/map-panel/map-panel.component';
import { BottomNavComponent } from './components/bottom-nav/bottom-nav.component';
import { BookRideComponent } from './components/pages/book-ride/book-ride.component';
import { MyTripsComponent } from './components/pages/my-trips/my-trips.component';
import { AccountComponent } from './components/pages/account/account.component';
import { ZonesByGovPipe } from './pipes/zones-by-gov.pipe';

@NgModule({
  declarations: [
    AppComponent,
    NavbarComponent,
    MapPanelComponent,
    BottomNavComponent,
    BookRideComponent,
    MyTripsComponent,
    AccountComponent,
    ZonesByGovPipe,
  ],
  imports: [
    BrowserModule,
    FormsModule,
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule {}
