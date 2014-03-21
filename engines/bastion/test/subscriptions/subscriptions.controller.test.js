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

describe('Controller: SubscriptionsController', function() {
    var $scope,
        Nutupane,
        unlimitedFilterFilter,
        gettext;

    beforeEach(module('Bastion.subscriptions', 'Bastion.test-mocks', 'alchemy.format'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };
    });

    beforeEach(module(function($provide) {
        $provide.value('gettext', function(a) {return a});
    }));

    beforeEach(inject(function($controller, $rootScope, $location, $injector, $filter) {
        $scope = $rootScope.$new();
        $q = $injector.get('$q');
        Subscription = $injector.get('MockResource').$new(),
        Provider = $injector.get('MockResource').$new();

        gettext = function(message) {
            return message;
        };
        unlimitedFilterFilter = $filter('unlimitedFilter');

        $controller('SubscriptionsController', {
            $scope: $scope,
            $q: $q,
            $location: $location,
            gettext: gettext,
            Nutupane: Nutupane,
            Subscription: Subscription,
            Provider: Provider,
            CurrentOrganization: 'CurrentOrganization',
            unlimitedFilterFilter: unlimitedFilterFilter
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it('sets the closeItem function to transition to the index page', function() {
        spyOn($scope, "transitionTo");
        $scope.table.closeItem();

        expect($scope.transitionTo).toHaveBeenCalledWith('subscriptions.index');
    });

    it('returns "x of y" for consumed where y can be unlimited', function() {
        var subscription = {consumed: 4, quantity: -1};
        expect($scope.formatConsumed(subscription)).toEqual("4 out of Unlimited");

        var subscription = {consumed: 4, quantity: 10};
        expect($scope.formatConsumed(subscription)).toEqual("4 out of 10");
    });

    it('returns "Physical" for non-virtual subscriptions', function() {
        var subscription = {'virt_only': false};
        expect($scope.subscriptionType(subscription)).toEqual("Physical");
    });

    it('returns "Virtual" for virtual subscriptions', function() {
        var subscription = {'virt_only': true};
        expect($scope.subscriptionType(subscription)).toEqual("Virtual");
    });
});
