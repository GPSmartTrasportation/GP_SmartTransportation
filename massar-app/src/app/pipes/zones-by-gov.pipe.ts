import { Pipe, PipeTransform } from '@angular/core';
import { Zone } from '../models/models';

@Pipe({ name: 'zonesByGov' })
export class ZonesByGovPipe implements PipeTransform {
  transform(zones: Zone[], governorate: string): Zone[] {
    return zones.filter(z => z.governorateName === governorate);
  }
}
