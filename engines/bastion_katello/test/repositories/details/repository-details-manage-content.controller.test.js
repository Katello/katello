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

describe('Controller: RepositoryManageContentController', function() {
    var $scope, translate, Repository, Nutupane, PuppetModule, Package, DockerImage;

    beforeEach(module(
        'Bastion.repositories',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            $state = $injector.get('$state'),
            Package = $injector.get('MockResource').$new();

        Repository = $injector.get('MockResource').$new();
        Repository.removeContent = function() {};

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            productId: 1,
            repositoryId: 1,
        };
        $state = { current: { name: 'products.details.repositories.manage-content.packages' } };

        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.removeRow = function() {};
        };

        translate = function(message) {
            return message;
        };

        $controller('RepositoryManageContentController', {
            $scope: $scope,
            $state: $state,
            translate: translate,
            Repository: Repository,
            PuppetModule: PuppetModule,
            Package: Package,
            DockerImage: DockerImage,
        });
    }));

    it('sets up a nutupane', function() {
        expect($scope.contentNutupane).not.toBe(undefined);
        expect($scope.detailsTable).not.toBe(undefined);
    });

    it('can remove content', function() {
        spyOn(Repository, 'removeContent');
        $scope.repository = {id: 'doh!'};
        $scope.detailsTable.getSelected = function() {
            return [{id: 'foo'}];
        };

        $scope.removeContent();

        expect(Repository.removeContent).toHaveBeenCalledWith({id: $scope.repository.id, uuids: ['foo']},
            jasmine.any(Function), jasmine.any(Function));
    });

    it('formats tags for a docker image', function() {
        var repoId = 1,
            tags,
            image,
            output = "latest, 2.11";

        tags = [
                {"name": "latest", "repository_id": 1},
                {"name": "latest", "repository_id": 2},
                {"name": "2.11",   "repository_id": 1}
               ];
        image = {"tags": tags};

        expect($scope.formatRepoDockerTags(image, repoId)).toEqual(output);
    });

});
