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

describe('Controller: SubscriptionProductsController', function() {
    var $scope;

    beforeEach(module(
        'Bastion.subscriptions',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Subscription = $injector.get('MockResource').$new(),
            Product = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {subscriptionId: 1};

        $controller('SubscriptionProductsController', {
            $scope: $scope,
            Subscription: Subscription,
            Product: Product,
            CurrentOrganization: "ACME"
        });
    }));

    it('should attach a products resource onto the scope', function() {
        expect($scope.products).toBeDefined();
        expect($scope.displayArea.working).toBe(false);
    });

});
