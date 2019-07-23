import angular from 'angular';
import BastionResource from './bastion-resource.factory';
import roundUp from './round-up.js';

export default angular.module('Bastion.utils', [])
  .factory('BastionResource', BastionResource)
  .filter('roundUp', roundUp)
  .name;
