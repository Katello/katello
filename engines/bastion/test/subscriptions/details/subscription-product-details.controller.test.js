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

describe('Controller: SubscriptionProductDetailsController', function() {
    var $scope;

    beforeEach(module('Bastion.subscriptions',
                      'subscriptions/views/subscriptions.html'));

    beforeEach(module(function ($stateProvider) {
        $stateProvider.state('subscriptions.fake', {});
    }));

    beforeEach(inject(function (_$controller_, $rootScope, $state) {
        $controller = _$controller_;
        $scope = $rootScope.$new();

        state = {
            transitionTo: function () {}
        };

        $controller('SubscriptionProductDetailsController', {
            $scope: $scope
        });
    }));

    it('should have enabled equal true', function() {
        expect($scope.expanded).toBe(true);
    });
});
