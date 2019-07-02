BASTION_MODULES = [];
angular.module('Bastion').value('currentLocale', 'Here');
angular.module('Bastion').value('CurrentOrganization', "ACME");
angular.module('Bastion').value('Authorization', {});
angular.module('Bastion').value('entriesPerPage', 20);
angular.module('Bastion').value('deleteHostOnUnregister', false);
angular.module('Bastion').value('markActiveMenu', function () {});
angular.module('Bastion').value('globalContentProxy', 'Test 1');
angular.module('Bastion').value('PageTitle', 'Bastion Page');
angular.module('Bastion').value('foreman', function () {});
angular.module('Bastion').constant('BastionConfig', {
    consumerCertRPM: "consumer_cert_rpm",
    markTranslated: false,
    relativeUrlRoot: '/'
});
angular.module('Bastion.auth').value('CurrentUser', {id: "User"});
angular.module('Bastion.auth').value('Permissions', []);

angular.module('templates', []);

angular.module('Bastion').config(function ($urlRouterProvider) {
    $urlRouterProvider.otherwise('/');
});
