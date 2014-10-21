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

describe('Controller: ContentHostSubscriptionsController', function() {
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

        ContentHost.removeSubscriptions = function() {};

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

        $scope.contentHost = new ContentHost({
            uuid: 12345,
            subscriptions: [{id: 1, quantity: 11}, {id: 2, quantity: 22}]
        });

        $scope.subscriptionsPane = {
            table: {}
        }

        $controller('ContentHostSubscriptionsController', {
            $scope: $scope,
            $location: $location,
            translate: translate,
            Subscription: Subscription,
            ContentHost: ContentHost,
            SubscriptionsHelper: SubscriptionsHelper
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.subscriptionsTable).toBeDefined();
    });

    it("allows removing subscriptions from the content host", function() {

        var expected = {uuid: 12345, subscriptions: [{id: 2}]};
        spyOn(ContentHost, 'removeSubscriptions');

        $scope.subscriptionsTable.getSelected = function() {
            return [{id: 2}];
        };

        $scope.removeSelected();
        expect(ContentHost.removeSubscriptions).toHaveBeenCalledWith(expected, jasmine.any(Function), jasmine.any(Function));
    });
});
