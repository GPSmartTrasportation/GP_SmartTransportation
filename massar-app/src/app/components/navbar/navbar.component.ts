import { Component, Input, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'app-navbar',
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.scss']
})
export class NavbarComponent {
  @Input() activeTab: 'book' | 'trips' | 'account' = 'book';
  @Output() tabChange = new EventEmitter<'book' | 'trips' | 'account'>();
}
