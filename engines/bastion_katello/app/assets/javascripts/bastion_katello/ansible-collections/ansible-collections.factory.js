(function () {
    'use strict';

    /**
     * @ngdoc factory
     * @name  Bastion.ansible-collections.factory:AnsibleCollection
     *
     * @description
     *   Provides a BastionResource for interacting with Ansible Collections
     */
    function AnsibleCollection(BastionResource) {

        return BastionResource('katello/api/v2/ansible_collections/:id',
            {'id': '@id'},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
            }
        );

    }

    angular
        .module('Bastion.ansible-collections')
        .factory('AnsibleCollection', AnsibleCollection);

    AnsibleCollection.$inject = ['BastionResource'];

})();
