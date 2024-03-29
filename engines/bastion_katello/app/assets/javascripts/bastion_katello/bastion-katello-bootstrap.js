var BASTION_MODULES = [
  'angular-blocks',
  'ngAnimate',
  'ngSanitize',
  'templates',
  'ui.bootstrap',
  'ui.bootstrap.tpls',
  'Bastion.auth',
  'Bastion.menu',
  'Bastion.i18n',
  'Bastion.features',
  'Bastion.routing',
  'Bastion.capsule-content',
  'Bastion.pulp-primary',
  'Bastion.activation-keys',
  'Bastion.architectures',
  'Bastion.common',
  'Bastion.content-views',
  'Bastion.content-views.versions',
  'Bastion.debs',
  'Bastion.docker-tags',
  'Bastion.files',
  'Bastion.ansible-collections',
  'Bastion.hosts',
  'Bastion.module-streams',
  'Bastion.environments',
  'Bastion.content-credentials',
  'Bastion.hosts',
  'Bastion.capsules',
  'Bastion.organizations',
  'Bastion.products',
  'Bastion.repositories',
  'Bastion.subscriptions',
  'Bastion.sync-plans',
  'Bastion.http-proxies',
  'Bastion.host-collections',
  'Bastion.content-hosts',
  'Bastion.tasks',
  'Bastion.settings'
];

// Check if the document has already been bootstrapped.
if (!angular.element(document).injector()) {
    angular.bootstrap(document, BASTION_MODULES);
}
