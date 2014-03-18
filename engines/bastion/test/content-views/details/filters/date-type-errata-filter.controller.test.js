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

describe('Controller: DateTypeErrataFilterController', function() {
    var $scope, Rule;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
            gettext = $injector.get('gettextMock');

        Rule = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.filter = Filter.get({id: 1});
        $scope.filter.rules = [{types: []}];
        $scope.filter['content_view'] = {id: 1};

        $scope.rule = {
            types: ['bugfix', 'security', 'enhancement']
        };

        $controller('DateTypeErrataFilterController', {
            $scope: $scope,
            gettext: gettext,
            Rule: Rule
        });
    }));

    it("provides a method to update the selected types", function() {
        $scope.updateTypes({'bugfix': true, 'security': true});

        expect($scope.rule.types).toEqual(['bugfix', 'security']);
    });

    it("should provide a method to add errata to the filter", function () {
        spyOn($scope, 'transitionTo');
        $scope.save($scope.rule, $scope.filter);

        expect($scope.successMessages.length).toBe(1);
        expect($scope.transitionTo).toHaveBeenCalled();
    });

});
