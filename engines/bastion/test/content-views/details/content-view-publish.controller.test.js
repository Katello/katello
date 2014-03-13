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

describe('Controller: ContentViewPublishController', function() {
    var $scope;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new(),
            gettext = $injector.get('gettextMock');

        ContentView.publish = function(options, callback) {  callback({id: 3}) };
        $scope = $injector.get('$rootScope').$new();

        $scope.contentView = ContentView.get({id: 1});
        $scope.contentView.versions = [];
        
        spyOn($scope, 'transitionTo');

        $controller('ContentViewPublishController', {
            $scope: $scope,
            gettext: gettext,
            ContentView: ContentView
        });
    }));

    it("puts an empty version on the scope", function() {
        expect($scope.version).toBeDefined();
    });

    it('provides a method to publish a content view version', function() {
        $scope.publish($scope.contentView, $scope.version);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-views.details.tasks.details',
            {contentViewId: $scope.contentView.id, taskId: 3});
    });

});
