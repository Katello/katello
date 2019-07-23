import angular from 'angular';
import uirouter from 'angular-ui-router';
import routes from './content-credentials.routes';
import ContentCredential from './content-credential.factory';
import contentTypeFilter from './content-type.filter';

export default angular.module('Bastion.content-credentials', [uirouter])
  .factory('ContentCredential', ContentCredential)
  .filter('contentTypeFilter', contentTypeFilter)
  .config(routes).name;
