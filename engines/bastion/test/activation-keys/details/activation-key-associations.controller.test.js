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

describe('Controller: ActivationKeyAssociationsController', function() {
    var $scope,
        ActivationKey,
        CurrentOrganization,
        translate;

    beforeEach(module(
        'Bastion.activation-keys',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ActivationKey = $injector.get('MockResource').$new();

        translate = function (message) {
            return message;
        };

        $scope = $injector.get('$rootScope').$new();

        ActivationKey = {
            contentHosts: function (params, callback) {
                return {};
            }
        };
        $scope.table = {
            working: true
        };
        $scope.activationKey = {};
        $scope.activationKey.$promise = { then: function (callback) { callback({}) } };

        $scope.$stateParams = {activationKeyId: 1};

        $controller('ActivationKeyAssociationsController', {
            $scope: $scope,
            translate: translate,
            ActivationKey: ActivationKey,
            ContentHostsHelper: {},
            CurrentOrganization: "ACME"
        });
    }));

    it('should attach a activation-key resource onto the scope', function() {
        expect($scope.activationKey).toBeDefined();
    });

});
