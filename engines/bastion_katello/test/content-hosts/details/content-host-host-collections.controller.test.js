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

describe('Controller: ContentHostHostCollectionsController', function() {
    var $scope,
        $controller,
        translate,
        ContentHost,
        CurrentOrganization;

    beforeEach(module(
        'Bastion.content-hosts',
        'Bastion.host-collections',
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

        ContentHost.saveHostCollections = function() {};

        CurrentOrganization = 'foo';

        translate = function(message) {
            return message;
        };

        $controller('ContentHostHostCollectionsController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            ContentHost: ContentHost,
            CurrentOrganization: CurrentOrganization
        });

        $scope.contentHost = new ContentHost({
            uuid: 2,
            hostCollections: [{id: 1, name: "lalala"}, {id: 2, name: "hello!"}],
            host_collection_ids: [1, 2]
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.hostCollectionsTable).toBeDefined();
    });

    it("allows removing host collections from the content host", function() {
        spyOn($scope.contentHost, '$update');

        $scope.hostCollectionsTable.getSelected = function() {
            return [{id: 1, name: "lalala"}];
        };

        $scope.removeHostCollections($scope.contentHost);
        expect($scope.contentHost.$update).toHaveBeenCalledWith({id: 2}, jasmine.any(Function), jasmine.any(Function));
    });
});
