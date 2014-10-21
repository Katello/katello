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

describe('Controller: NewContentViewController', function() {
    var $scope,
        $controller,
        dependencies,
        FormUtils,
        ContentView;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        $controller = $injector.get('$controller');

        ContentView = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        FormUtils = {
            labelize: function () {}
        };

        $scope.contentViewForm = $injector.get('MockForm');
        $scope.$parent.table = {addRow: function () {}};

        dependencies = {
            $scope: $scope,
            ContentView: ContentView,
            FormUtils: FormUtils,
            CurrentOrganization: 'CurrentOrganization'
        };

        $controller('NewContentViewController', dependencies);
    }));

    it('should attach a new content view resource on to the scope', function() {
        expect($scope.contentView).toBeDefined();
    });

    it('should save a new content view resource', function() {
        var contentView = $scope.contentView;

        spyOn($scope.$parent.table, 'addRow');
        spyOn($scope, 'transitionTo');
        spyOn(contentView, '$save').andCallThrough();
        $scope.save(contentView);

        expect(contentView.$save).toHaveBeenCalled();
        expect($scope.$parent.table.addRow).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('content-views.details.repositories.available',
                                                         {contentViewId: 1})
    });

    it("should save a new composite content view resource", function () {
        var contentView = $scope.contentView;
        spyOn($scope.$parent.table, 'addRow');
        spyOn($scope, 'transitionTo');
        spyOn(contentView, '$save').andCallThrough();

        contentView.composite = true;
        $scope.save(contentView);

        expect(contentView.$save).toHaveBeenCalled();
        expect($scope.$parent.table.addRow).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('content-views.details.composite-content-views.available',
            {contentViewId: 1})
    });

    it('should fetch a label whenever the name changes', function() {
        spyOn(FormUtils, 'labelize');

        $scope.contentView.name = 'ChangedName';
        $scope.$apply();

        expect(FormUtils.labelize).toHaveBeenCalled();
    });
});

