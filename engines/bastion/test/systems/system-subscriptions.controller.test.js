/**
 * Copyright 2013 Red Hat, Inc.
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

describe('Controller: SystemSubscriptionsController', function() {
    var $scope, SystemSubscription, Routes, i18nFilter, Nutupane, subscription, expectedTable, expectedRows;

    // load the systems module and template
    beforeEach(module('Bastion.systems', 'Bastion.test-mocks'));

    // Set up mocks
    beforeEach(function() {
        expectedRows = [];

        expectedTable = {
            showColumns: function() {},
            getSelected: function() {
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
        Routes = {
            apiSystemsPath: function() { return '/api/systems';},
        };
        i18nFilter = function(message) {
            return message;
        };
        SystemSubscription = {
            remove: function() {},
            save: function() {}
        };

        subscription = {
            'multi_entitlement': false,
            available: 0,
            selected: false
        }
    });

    // Initialize controller
    beforeEach(inject(function($controller, $rootScope) {
        $scope = $rootScope.$new();

        $controller('SystemSubscriptionsController', {
            $scope: $scope,
            i18nFilter: i18nFilter,
            SystemSubscription: SystemSubscription,
            System: {},
            Nutupane: Nutupane
        });
    }));

    it("sets up the current subscriptions nutupane table.", function() {
        expect($scope.currentSubscriptionsTable).toBe(expectedTable);
    });

    it("sets up the available subscriptions nutupane table.", function() {
        expect($scope.availableSubscriptionsTable).toBe(expectedTable);
    });

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

            $scope.system = {
                uuid: 'abcde',
                $get: function() {}
            };
        });

        it("by removing the selected subscriptions", function() {
            spyOn(SystemSubscription, 'remove');

            expectedTable.getSelected = function() {
                return [expectedRows[1]];
            };

            $scope.removeSubscriptions();

            expect(SystemSubscription.remove).toHaveBeenCalledWith({systemId: 'abcde', id: 2},
                jasmine.any(Function), jasmine.any(Function)
            );
        });

        it("by removing all subscriptions if all are selected", function() {
            spyOn(SystemSubscription, 'remove');

            expectedTable.allSelected = true;

            $scope.removeSubscriptions();

            expect(SystemSubscription.remove).toHaveBeenCalledWith({systemId: 'abcde'},
                jasmine.any(Function), jasmine.any(Function)
            );
        });

        it("by attaching the selected subscriptions", function() {
            spyOn(SystemSubscription, 'save');

            expectedTable.getSelected = function() {
                return [expectedRows[1]];
            };

            $scope.attachSubscriptions();

            expect(SystemSubscription.save).toHaveBeenCalledWith({systemId: 'abcde',
                    pool: 'b', quantity: 1}, jasmine.any(Function), jasmine.any(Function)
            );
        });
    });
});

