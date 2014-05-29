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

describe('Controller: RepositoryManagePackagesController', function() {
    var $scope, translate, Nutupane, Repository;

    beforeEach(module(
        'Bastion.repositories',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            Package = $injector.get('MockResource').$new();

        Repository = $injector.get('MockResource').$new();
        Repository.removePackages = function() {};

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            productId: 1,
            repositoryId: 1
        };

        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.removeRow = function() {};
        };

        translate = function(message) {
            return message;
        };

        $controller('RepositoryManagePackagesController', {
            $scope: $scope,
            Nutupane: Nutupane,
            translate: translate,
            Package: Package,
            Repository: Repository
        });
    }));

    it('sets up a nutupane', function() {
        expect($scope.packagesNutupane).not.toBe(undefined);
        expect($scope.detailsTable).not.toBe(undefined);
    });

    it('can remove a package', function() {
        spyOn(Repository, 'removePackages');
        $scope.reopsitory = {id: 'doh!'};
        $scope.detailsTable.getSelected = function() {
            return [{id: 'foo'}];
        };

        $scope.removePackages();

        expect(Repository.removePackages).toHaveBeenCalledWith({id: $scope.repository.id, uuids: ['foo']},
            jasmine.any(Function), jasmine.any(Function));
    })

});
