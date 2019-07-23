import angular from 'angular';
import Nutupane from './nutupane.factory';
import TableCache from './table-cache.service';
import Notification from './notification.service';

export default angular.module('Bastion.components', [])
  .service('TableCache', TableCache)
  .service('Notification', Notification)
  .factory('Nutupane', Nutupane)
  .name;
