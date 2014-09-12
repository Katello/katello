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

describe('Controller: ContentViewHistoryController', function() {
    var $scope, history, Nutupane;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new(),
            translate = function(text) {return text};

        history = [];
        ContentView.history = function(options, callback) {  callback(history) };
        $scope = $injector.get('$rootScope').$new();
        $scope.contentView = ContentView.get({id: 1});

        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.removeRow = function() {};
            this.get = function() {};
        };

        spyOn($scope, 'transitionTo');

        $controller('ContentViewHistoryController', {
            $scope: $scope,
            ContentView: ContentView,
            Nutupane: Nutupane,
            translate: translate
        });
    }));

    it('defines details table', function() {
        expect($scope.detailsTable).toNotBe(undefined);
    });

});
