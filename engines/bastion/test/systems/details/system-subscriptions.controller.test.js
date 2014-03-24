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

describe('Controller: SystemSubscriptionsController', function() {
    var $scope,
        $controller,
        gettext,
        System,
        Subscription,
        Nutupane,
        expectedTable,
        expectedRows,
        SystemsHelper,
        SubscriptionsHelper;

    beforeEach(module(
        'Bastion.systems',
        'Bastion.subscriptions',
        'Bastion.test-mocks',
        'systems/details/views/system-groups.html',
        'systems/views/systems.html',
        'systems/views/systems-table-full.html'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        System = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();
        $location = $injector.get('$location');
        SystemsHelper = $injector.get('SystemsHelper');
        SubscriptionsHelper = $injector.get('SubscriptionsHelper');

        System.removeSubscriptions = function() {};

        gettext = function(message) {
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

        $controller('SystemSubscriptionsController', {
            $scope: $scope,
            $location: $location,
            gettext: gettext,
            Subscription: Subscription,
            System: System,
            Nutupane: Nutupane,
            SystemsHelper: SystemsHelper,
            SubscriptionsHelper: SubscriptionsHelper
        });

        $scope.system = new System({
            uuid: 12345,
            subscriptions: [{id: 1, quantity: 11}, {id: 2, quantity: 22}]
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.subscriptionsTable).toBeDefined();
    });

    it("allows removing system groups from the system", function() {

        var expected = {uuid: 12345, subscriptions: [{id: 2}]};
        spyOn(System, 'removeSubscriptions');

        $scope.subscriptionsTable.getSelected = function() {
            return [{id: 2}];
        };

        $scope.removeSelected();
        expect(System.removeSubscriptions).toHaveBeenCalledWith(expected, jasmine.any(Function), jasmine.any(Function));
    });
});
