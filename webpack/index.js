/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/extensions */
/* eslint-disable import/no-unresolved */

import angular from 'angular';
import uirouter from 'angular-ui-router';
import angularResource from 'angular-resource';
import angularUiBootstrap from 'angular-ui-bootstrap';
import componentRegistry from 'foremanReact/components/componentRegistry';
import 'angular-blocks';

import Application from './containers/Application/index';
import routes from './angular/app.routes';
import bastionComponents from './angular/bastion/components';
import bastionUtils from './angular/bastion/utils';
import i18n from './angular/bastion/i18n';
import angularTest from './angular/angular_test';
import contentCredentials from './angular/content-credentials';
import './redux';
// Not currently mocking anything
// import './services/api/setupMocks';


componentRegistry.register({
  name: 'katello',
  type: Application,
});

const ANGULAR_MODULES = [
  uirouter,
  angularResource,
  angularTest,
  angularUiBootstrap,
  'angular-blocks',
  bastionUtils,
  i18n,
  bastionComponents,
  contentCredentials,
];

angular.module('Bastion', ANGULAR_MODULES)
  .config(routes);
