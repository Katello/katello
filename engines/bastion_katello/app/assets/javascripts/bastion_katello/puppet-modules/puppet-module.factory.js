(function () {
    'use strict';

    /**
     * @ngdoc factory
     * @name  Bastion.puppet-modules.factory:PuppetModule
     *
     * @description
     *   Provides a BastionResource for interacting with Puppet Modules
     */
    function PuppetModule(BastionResource) {

        return BastionResource('katello/api/v2/puppet_modules/:id',
            {'id': '@id'},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
            }
        );

    }

    angular
        .module('Bastion.puppet-modules')
        .factory('PuppetModule', PuppetModule);

    PuppetModule.$inject = ['BastionResource'];

})();
