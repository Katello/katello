1/**
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

describe('Controller: ContentHostAddSystemGroupsController', function() {
    var $scope,
        $controller,
        translate,
        ContentHost,
        CurrentOrganization;

    beforeEach(module(
        'Bastion.content-hosts',
        'Bastion.system-groups',
        'Bastion.test-mocks',
        'content-hosts/details/views/system-groups.html',
        'content-hosts/views/content-hosts.html',
        'content-hosts/views/content-hosts-table-full.html'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        ContentHost = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        ContentHost.saveSystemGroups = function() {};

        CurrentOrganization = 'foo';

        translate = function(message) {
            return message;
        };

        $controller('ContentHostAddSystemGroupsController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            ContentHost: ContentHost,
            CurrentOrganization: CurrentOrganization
        });

        $scope.contentHost = new ContentHost({
            uuid: 2,
            systemGroups: [{id: 1, name: "lalala"}],
            system_group_ids: [1]
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.systemGroupsTable).toBeDefined();
    });

    it("allows adding system groups to the content host", function() {
        spyOn($scope.contentHost, '$update');

        $scope.systemGroupsTable.getSelected = function() {
            return [{id: 2, name: "hello!"}];
        };

        $scope.addSystemGroups($scope.contentHost);
        expect($scope.contentHost.$update).toHaveBeenCalledWith({id: 2}, jasmine.any(Function), jasmine.any(Function));
    });
});
