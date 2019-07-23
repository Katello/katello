import angular from 'angular';
import translate from './translate.service';
import 'angular-gettext';

export default angular.module('Bastion.i18n', ['gettext'])
  .service(translate)
  .name;
