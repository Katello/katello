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

describe('Controller: SubscriptionDetailsController', function() {
    var $scope, gettext;

    beforeEach(module(
        'Bastion.subscriptions',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Subscription = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {subscriptionId: 1};

        gettext = function(a) { return a };

        $controller('SubscriptionDetailsController', {
            $scope: $scope,
            gettext: gettext,
            Subscription: Subscription
        });
    }));

    it('should attach a subscription resource onto the scope', function() {
        expect($scope.subscription).toBeDefined();
    });

    describe('provides a subscription limits method', function() {

        it("returns the number of sockets for subscription with socket limit", function() {
            var subscription = {sockets: 5};
            expect($scope.subscriptionLimits(subscription)).toBe("Sockets: 5");
        });

        it("returns the amount of ram for subscription with memory limit", function() {
            var subscription = {ram: 4};
            expect($scope.subscriptionLimits(subscription)).toBe("RAM: 4 GB");
        });

        it("returns sockets and cores for subscription with socket and core limit", function() {
            var subscription = {sockets: 2, cores: 4};
            expect($scope.subscriptionLimits(subscription)).toBe("Sockets: 2, Cores: 4");
        });

    });

});
