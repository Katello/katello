(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.content-views.versions.controller:ContentViewVersion
     *
     * @description
     *   Handles fetching of a content view version based on the route ID and putting it
     *   on the scope.
     */
    function ContentViewVersionController($scope, ContentViewVersion) {

        $scope.version = ContentViewVersion.get({id: $scope.$stateParams.versionId});

    }

    angular
        .module('Bastion.content-views.versions')
        .controller('ContentViewVersionController', ContentViewVersionController);

    ContentViewVersionController.$inject = ['$scope', 'ContentViewVersion'];

})();
