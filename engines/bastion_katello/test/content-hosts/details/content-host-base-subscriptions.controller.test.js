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

describe('Controller: ContentHostBaseSubscriptionsController', function() {
    var $scope,
        $controller,
        translate,
        ContentHost,
        Subscription,
        Nutupane,
        expectedTable,
        expectedRows;

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
        
        ContentHost.refreshSubscriptions = function() {};

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

        $scope.contentHost = new ContentHost({
            uuid: 12345,
            subscriptions: [{id: 1, quantity: 11}, {id: 2, quantity: 22}]
        });

        
        $controller('ContentHostBaseSubscriptionsController', {
            $scope: $scope,
            $location: $location,
            translate: translate,
            CurrentOrganization: 'organization',
            Subscription: Subscription,
            ContentHost: ContentHost,
            Nutupane: Nutupane
        });
    }));

    it('attaches available subscriptions to the scope', function() {
        expect($scope.addSubscriptionsPane).toBeDefined();
    });

    it('attaches current subscriptions to the scope', function() {
        expect($scope.subscriptionsPane).toBeDefined();
    });

    it("allows auto attaching subscriptions to the content host", function() {
        spyOn(ContentHost, 'refreshSubscriptions');
        $scope.autoAttachSubscriptions();
        expect(ContentHost.refreshSubscriptions).toHaveBeenCalledWith({uuid: $scope.contentHost.uuid}, jasmine.any(Function), jasmine.any(Function));
    });
});