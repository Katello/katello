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

describe('Controller: ContentViewDeletionController', function() {
    var $scope,
        versions,
        ContentView;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        versions = [{version: 1, environments:[{name: "name"}]}, {version: 2, environments: []}];
        ContentView = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {contentViewId: 1};
        $scope.contentView = {id: '99'};

        $scope.reloadVersions = function () {
            $scope.versions = versions;
        };

        $controller('ContentViewDeletionController', {
            $scope: $scope,
            ContentView: ContentView
        });
    }));

    it("properly detects conflicting versions", function() {
        expect($scope.conflictingVersions()[0]).toBe(versions[0]);
    });

    it("properly extracts environment names", function () {
        expect($scope.environmentNames(versions[0])[0]).toBe("name");
    });

    it("properly deletes the view", function () {
        spyOn(ContentView, 'remove');
        $scope.delete();
        expect(ContentView.remove).toHaveBeenCalledWith({id: $scope.contentView.id},
            jasmine.any(Function), jasmine.any(Function));
    });
});
