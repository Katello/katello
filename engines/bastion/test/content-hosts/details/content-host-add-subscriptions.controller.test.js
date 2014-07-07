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

describe('Controller: ContentHostAddSubscriptionsController', function() {
    var $scope,
        $controller,
        translate,
        ContentHost,
        Subscription,
        expectedTable,
        expectedRows,
        SubscriptionsHelper;

    beforeEach(module(
        'Bastion.content-hosts',
        'Bastion.subscriptions',
        'Bastion.test-mocks',
        'content-hosts/details/views/host-collections.html',
        'content-hosts/views/content-hosts.html',
        'content-hosts/views/content-hosts-table-full.html'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        ContentHost = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();
        $location = $injector.get('$location');
        SubscriptionsHelper = $injector.get('SubscriptionsHelper');

        ContentHost.addSubscriptions = function() {};

        translate = function(message) {
            return message;
        };

        expectedRows = [];

        expectedTable = {
            showColumns: function() {},
            getSelected: function() {
                return expectedRows;
            },
            rows: function () {
                return expectedRows;
            },
            selectAll: function() {},
            allSelected: false
        };
        Nutupane = function() {
            this.table = expectedTable;
            this.removeRow = function() {};
            this.get = function() {};
            this.query = function() {};
            this.refresh = function() {};
        };
        translate = function(message) {
            return message;
        };
        ContentHostSubscription = {
            remove: function() {},
            save: function() {}
        };

        subscription = {
            'multi_entitlement': false,
            available: 0,
            selected: false
        }

        $scope.contentHost = new ContentHost({
            uuid: 12345,
            subscriptions: [{id: 1, quantity: 11}, {id: 2, quantity: 22}]
        });

        $scope.addSubscriptionsPane = {
            table: {}
        }

        $controller('ContentHostAddSubscriptionsController', {
            $scope: $scope,
            $location: $location,
            translate: translate,
            CurrentOrganization: 'organization',
            Subscription: Subscription,
            ContentHost: ContentHost,
            SubscriptionsHelper: SubscriptionsHelper
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.addSubscriptionsTable).toBeDefined();
    });

    it("allows adding subscriptions to the content host", function() {

        var expected = {uuid: 12345, subscriptions: [
                                                      {id: 2, quantity: 0},
                                                      {id: 3, quantity: 1},
                                                      {id: 4, quantity: 1}
                                                    ]};
        spyOn(ContentHost, 'addSubscriptions');

        $scope.addSubscriptionsTable.getSelected = function() {
            return [
                     {id: 2, 'multi_entitlement': true},
                     {id: 3, 'multi_entitlement': true, 'amount': 1},
                     {id: 4, 'multi_entitlement': false}
                   ];
        };

        $scope.addSelected();
        expect(ContentHost.addSubscriptions).toHaveBeenCalledWith(expected, jasmine.any(Function), jasmine.any(Function));
    });

    /*
    describe("provides a filter for the available display", function() {
        var expected;

        it("it should be 'Unlimited' if -1", function() {
            subscription.available = -1;
            expected = subscription;
            expected.availableDisplay = 'Unlimited';

            expect($scope.availableSubscriptionsTable.formatAvailableDisplay(subscription)).toBe(expected);
        });

        it("it should be the number if not -1", function() {
            subscription.available = 2;
            expected = subscription;

            expect($scope.availableSubscriptionsTable.formatAvailableDisplay(subscription)).toBe(expected);
        });
    });

    describe("provides a way to determine if the selector should be shown", function() {
        it("shows the selector if all three conditions are met", function() {
            subscription['multi_entitlement'] = true;
            expect($scope.availableSubscriptionsTable.showSelector(subscription)).toBe(false);

            subscription.available = 2;
            expect($scope.availableSubscriptionsTable.showSelector(subscription)).toBe(false);

            subscription.selected = true;
            expect($scope.availableSubscriptionsTable.showSelector(subscription)).toBe(true);
        });

        it("does not show the selector if conditions are not met", function() {
            expect($scope.availableSubscriptionsTable.showSelector(subscription)).toBe(false);
        });
    });

    describe("provides a way to attach and remove subscriptions", function() {
        beforeEach(function() {
            expectedRows = [
                {entitlementId: 1, cp_id: 'a'},
                {entitlementId: 2, cp_id: 'b'},
                {entitlementId: 3, cp_id: 'c'}
            ];

            $scope.contentHost = {
                uuid: 'abcde',
                $get: function() {}
            };
        });

        it("by removing the selected subscriptions", function() {
            spyOn(ContentHostSubscription, 'remove');

            expectedTable.getSelected = function() {
                return [expectedRows[1]];
            };

            $scope.removeSubscriptions();

            expect(ContentHostSubscription.remove).toHaveBeenCalledWith({contentHostId: 'abcde', id: 2},
                jasmine.any(Function), jasmine.any(Function)
            );
        });

        it("by removing all subscriptions if all are selected", function() {
            spyOn(ContentHostSubscription, 'remove');

            expectedTable.allSelected = true;

            $scope.removeSubscriptions();

            expect(ContentHostSubscription.remove).toHaveBeenCalledWith({contentHostId: 'abcde'},
                jasmine.any(Function), jasmine.any(Function)
            );
        });

        it("by attaching the selected subscriptions", function() {
            spyOn(ContentHostSubscription, 'save');

            expectedTable.getSelected = function() {
                return [expectedRows[1]];
            };

            $scope.attachSubscriptions();

            expect(ContentHostSubscription.save).toHaveBeenCalledWith({contentHostId: 'abcde',
                    pool: 'b', quantity: 1}, jasmine.any(Function), jasmine.any(Function)
            );
        });
    });
    */
});
