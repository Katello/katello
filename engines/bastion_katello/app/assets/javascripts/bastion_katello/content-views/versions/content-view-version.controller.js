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
