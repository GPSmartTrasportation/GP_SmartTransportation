import { Component, Input, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'app-bottom-nav',
  template: `
    <nav class="bottom-nav">
      <button class="bottom-nav-item" [class.active]="active==='book'" (click)="tabChange.emit('book')">
        <span class="material-icons">directions_car</span>
        <span>Book Ride</span>
      </button>
      <button class="bottom-nav-item" [class.active]="active==='trips'" (click)="tabChange.emit('trips')">
        <span class="material-icons">history</span>
        <span>My Trips</span>
      </button>
      <button class="bottom-nav-item" [class.active]="active==='account'" (click)="tabChange.emit('account')">
        <span class="material-icons">person</span>
        <span>Account</span>
      </button>
    </nav>
  `,
  styles: [`
    .bottom-nav {
      position: fixed;
      bottom: 0;
      left: 0;
      right: 0;
      background: white;
      border-top: 1px solid var(--border);
      display: flex;
      z-index: 200;
      padding-bottom: env(safe-area-inset-bottom);
    }
    .bottom-nav-item {
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 3px;
      padding: 10px;
      font-size: 10px;
      font-weight: 500;
      color: var(--text-muted);
      background: none;
      border: none;
      cursor: pointer;
      transition: color 0.15s;
      .material-icons { font-size: 22px; }
    }
    .bottom-nav-item.active {
      color: var(--teal);
    }
    @media (min-width: 769px) {
      .bottom-nav { display: none; }
    }
  `]
})
export class BottomNavComponent {
  @Input() active: 'book' | 'trips' | 'account' = 'book';
  @Output() tabChange = new EventEmitter<'book' | 'trips' | 'account'>();
}
