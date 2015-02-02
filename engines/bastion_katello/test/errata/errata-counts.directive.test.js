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
describe('Directive: errataCounts', function() {
    var $scope, $compile, element;

    beforeEach(module(
        'Bastion.errata',
        'errata/views/errata-counts.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        $compile = _$compile_;
        $scope = _$rootScope_;
    }));

    beforeEach(function() {
        $scope.errataCounts = {bufix: 1, enhancement: 2, security: 3, total: 6};
        element = '<span errata-counts="errataCounts"></span>';
        element = $compile(element)($scope);
        $scope.$digest();
    });

    it("displays totals for each type of errata", function() {
        expect(element.find('[title="Security"]').length).toBe(1);
        expect(element.find('[title="Bug Fix"]').length).toBe(1);
        expect(element.find('[title="Enhancement"]').length).toBe(1);
    });

    it("displays icons for each type of errata", function() {
        expect(element.find('.fa-warning').length).toBe(1);
        expect(element.find('.fa-bug').length).toBe(1);
        expect(element.find('.fa-plus-square').length).toBe(1);
    });
});
