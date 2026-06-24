import { Component, Input, OnChanges, AfterViewInit, OnDestroy, ElementRef, ViewChild } from '@angular/core';
import * as L from 'leaflet';
import { Zone } from '../../models/models';

@Component({
  selector: 'app-map-panel',
  templateUrl: './map-panel.component.html',
  styleUrls: ['./map-panel.component.scss']
})
export class MapPanelComponent implements AfterViewInit, OnChanges, OnDestroy {
  @Input() pickup: Zone | null = null;
  @Input() dropoff: Zone | null = null;
  @Input() step: string = 'booking';

  @ViewChild('mapHost') mapHost!: ElementRef<HTMLDivElement>;

  private map?: L.Map;
  private pickupMarker?: L.Marker;
  private dropoffMarker?: L.Marker;
  private routeLine?: L.Polyline;
  private mapReady = false;

  ngAfterViewInit() {
    this.initMap();
    this.mapReady = true;
    this.updateMap();
  }

  ngOnChanges() {
    if (this.mapReady) {
      this.updateMap();
    }
  }

  ngOnDestroy() {
    this.map?.remove();
  }

  private initMap() {
    this.map = L.map(this.mapHost.nativeElement, {
      center: [30.04, 31.24],
      zoom: 11,
      zoomControl: false,
    });

    L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
      attribution: '&copy; OpenStreetMap &copy; CARTO',
      maxZoom: 19,
    }).addTo(this.map);

    L.control.zoom({ position: 'bottomleft' }).addTo(this.map);
  }

  private pinIcon(color: string, city: string, zone: string): L.DivIcon {
    return L.divIcon({
      className: 'massar-pin-icon',
      html: `
        <div class="massar-pin" style="--pin:${color}">
          <span class="massar-pin-head"></span>
          <span class="massar-pin-tail"></span>
          <div class="massar-pin-text">
            <strong>${this.escape(city)}</strong>
            <em>${this.escape(zone)}</em>
          </div>
        </div>`,
      iconSize: [1, 1],
      iconAnchor: [9, 22],
    });
  }

  private escape(text: string): string {
    return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  private updateMap() {
    if (!this.map) return;

    if (this.pickupMarker) {
      this.map.removeLayer(this.pickupMarker);
      this.pickupMarker = undefined;
    }
    if (this.dropoffMarker) {
      this.map.removeLayer(this.dropoffMarker);
      this.dropoffMarker = undefined;
    }
    if (this.routeLine) {
      this.map.removeLayer(this.routeLine);
      this.routeLine = undefined;
    }

    if (this.pickup) {
      this.pickupMarker = L.marker([this.pickup.lat, this.pickup.lng], {
        icon: this.pinIcon('#4a9d8f', this.pickup.cityName, this.pickup.name),
        zIndexOffset: 1000,
      }).addTo(this.map);
    }

    if (this.dropoff) {
      this.dropoffMarker = L.marker([this.dropoff.lat, this.dropoff.lng], {
        icon: this.pinIcon('#f97316', this.dropoff.cityName, this.dropoff.name),
        zIndexOffset: 1000,
      }).addTo(this.map);
    }

    if (this.pickup && this.dropoff) {
      this.drawRouteAlongStreets();
      const bounds = L.latLngBounds(
        [this.pickup.lat, this.pickup.lng],
        [this.dropoff.lat, this.dropoff.lng]
      );
      this.map.fitBounds(bounds, { padding: [60, 60], maxZoom: 14 });
    } else if (this.pickup) {
      this.map.setView([this.pickup.lat, this.pickup.lng], 14, { animate: true });
    } else if (this.dropoff) {
      this.map.setView([this.dropoff.lat, this.dropoff.lng], 14, { animate: true });
    } else {
      this.map.setView([30.04, 31.24], 11, { animate: true });
    }

    setTimeout(() => this.map?.invalidateSize(), 0);
  }

  private drawRouteAlongStreets() {
    if (!this.map || !this.pickup || !this.dropoff) return;

    const fallback: L.LatLngExpression[] = [
      [this.pickup.lat, this.pickup.lng],
      [this.dropoff.lat, this.dropoff.lng],
    ];

    const url =
      `https://router.project-osrm.org/route/v1/driving/` +
      `${this.pickup.lng},${this.pickup.lat};${this.dropoff.lng},${this.dropoff.lat}` +
      `?overview=full&geometries=geojson`;

    fetch(url)
      .then(res => res.json())
      .then(data => {
        const coords: number[][] | undefined = data?.routes?.[0]?.geometry?.coordinates;
        if (!coords?.length || !this.map) {
          this.renderRoute(fallback);
          return;
        }
        const latlngs: L.LatLngExpression[] = coords.map(c => [c[1], c[0]]);
        this.renderRoute(latlngs);
      })
      .catch(() => this.renderRoute(fallback));
  }

  private renderRoute(latlngs: L.LatLngExpression[]) {
    if (!this.map) return;
    if (this.routeLine) {
      this.map.removeLayer(this.routeLine);
    }
    this.routeLine = L.polyline(latlngs, {
      color: '#4a9d8f',
      weight: 5,
      opacity: 0.9,
      lineCap: 'round',
      lineJoin: 'round',
      dashArray: '10, 6',
    }).addTo(this.map);
    this.routeLine.bringToBack();
  }

  get hasRoute(): boolean {
    return !!(this.pickup && this.dropoff);
  }

  get statusLabel(): string {
    switch (this.step) {
      case 'searching': return 'Finding your driver...';
      case 'driver_on_way': return 'Driver is on the way';
      case 'completed': return 'Trip Completed';
      default: return this.hasRoute ? 'Route Preview' : 'Select pickup & drop-off';
    }
  }
}
