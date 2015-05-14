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
        return BastionResource('/katello/api/v2/package_groups/:id',
            {'id': '@id'}
        );
    }

    angular
        .module('Bastion.package-groups')
        .factory('PackageGroup', PackageGroup);

    PackageGroup.$inject = ['BastionResource'];

})();
