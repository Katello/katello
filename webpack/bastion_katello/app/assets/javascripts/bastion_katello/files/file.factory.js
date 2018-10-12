(function () {
    'use strict';

    /**
     * @ngdoc factory
     * @name  Bastion.files.factory:File
     *
     * @description
     *   Provides a BastionResource for interacting with Files
     */
    function File(BastionResource) {

        return BastionResource('katello/api/v2/files/:id',
            {'id': '@id'},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
            }
        );

    }

    angular
        .module('Bastion.files')
        .factory('File', File);

    File.$inject = ['BastionResource'];

})();
