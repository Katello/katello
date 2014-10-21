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

describe('Controller: ContentViewDetailsController', function() {
    var $scope,
        ContentView,
        newContentView;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            translate = $injector.get('translateMock');

        newContentView = {id: 7};
        ContentView = $injector.get('MockResource').$new();
        ContentView.copy = function(params, success){success(newContentView)};

        ContentViewVersion = $injector.get('MockResource').$new();
        AggregateTask = {newAggregate: function(){}};

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {contentViewId: 1};
        $scope.table = {
            addRow: function() {}
        };

        $controller('ContentViewDetailsController', {
            $scope: $scope,
            ContentView: ContentView,
            ContentViewVersion: ContentViewVersion,
            AggregateTask: AggregateTask,
            translate: translate
        });
    }));

    it("retrieves and puts the content view on the scope", function() {
        expect($scope.contentView).toBeDefined();
    });

    it("defines a method for deloading the versions", function() {
        expect($scope.reloadVersions).toBeDefined();
    });

    it('provides a method to save a product', function() {
        $scope.save($scope.contentView);

        expect($scope.successMessages.length).toBe(1);
    });

    it('should be able to copy the content view', function(){
        spyOn($scope, 'transitionTo');
        spyOn($scope.table, 'addRow');
        $scope.copy(name);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-views.details.info', {contentViewId: newContentView.id});
        expect($scope.table.addRow).toHaveBeenCalledWith(newContentView);
    });
});
