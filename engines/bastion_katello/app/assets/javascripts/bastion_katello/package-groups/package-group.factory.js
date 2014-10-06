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

(function () {
    'use strict';

    /**
     * @ngdoc factory
     * @name  Bastion.package-groups.factory:PackageGroup
     *
     * @description
     *   Provides a BastionResource for interacting with Package Groups
     */
    function PackageGroup(BastionResource) {
        return BastionResource('/api/v2/package_groups/:id',
            {'id': '@id'}
        );
    }

    angular
        .module('Bastion.package-groups')
        .factory('PackageGroup', PackageGroup);

    PackageGroup.$inject = ['BastionResource'];

})();
