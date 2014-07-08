/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

angular.module('Bastion').value('currentLocale', 'Here');
angular.module('Bastion').value('CurrentOrganization', "ACME");
angular.module('Bastion').value('CurrentUser', {id: "User"});
angular.module('Bastion').value('Permissions', []);
angular.module('Bastion').value('Authorization', {});
angular.module('Bastion').value('markActiveMenu', function () {});
angular.module('Bastion').constant('BastionConfig', {
    consumerCertRPM: "consumer_cert_rpm",
    markTranslated: false
});

angular.module('templates', []);

angular.module('Bastion').config(function ($urlRouterProvider) {
    $urlRouterProvider.otherwise('/');
});

