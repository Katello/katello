import angular from 'angular';
import 'angular-gettext';
import translate from './translate.service';

export default angular.module('Bastion.i18n', ['gettext'])
  .service(translate)
  .name;
