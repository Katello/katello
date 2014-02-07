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
 */

describe('Directive: setTitle', function () {
    var $scope, $compile, PageTitle, resource, element;

    beforeEach(module('Bastion.widgets', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
       PageTitle = {
           setTitle: function () {}
       };

       $provide.value('PageTitle', PageTitle);
    }));

    beforeEach(inject(function (_$compile_, _$rootScope_, MockResource) {
        $compile = _$compile_;
        $scope = _$rootScope_;
        resource = MockResource.$new().get({id: 1});
    }));

    it("should wait on a promise if the model is provided", function () {
        spyOn(PageTitle, 'setTitle');
        $scope.resource = resource;
        element = angular.element('<div page-title ng-model="resource">new awesome title</div>');

        $compile(element)($scope);
        expect(PageTitle.setTitle).not.toHaveBeenCalled();

        $scope.$digest();

        expect(PageTitle.setTitle).toHaveBeenCalledWith('new awesome title', jasmine.any(Object));
    });

    it("should set the page title without waiting for a $promise if none exists", function () {
        spyOn(PageTitle, 'setTitle');
        element = angular.element('<div page-title>new awesome title</div>');

        $compile(element)($scope);

        expect(PageTitle.setTitle).toHaveBeenCalledWith('new awesome title', jasmine.any(Object));
    });
});
