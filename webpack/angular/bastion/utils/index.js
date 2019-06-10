import angular from 'angular';
import BastionResource from './bastion-resource.factory';

export default angular.module("Bastion.utils", [])
                      .factory('BastionResource', BastionResource)
                      .name