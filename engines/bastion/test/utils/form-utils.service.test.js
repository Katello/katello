/**
 * Copyright 2013 Red Hat, Inc.
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

describe('Service:formUtils', function() {
    var FormUtils, $httpBackend;

    beforeEach(module('Bastion.utils'));

    beforeEach(inject(function($injector) {
        FormUtils = $injector.get('FormUtils');
        $httpBackend = $injector.get('$httpBackend');
    }));

    it("provides a function that turns a name into a label", function() {
        var model = {name: 'ChangedName'}, modelForm = {};

        $httpBackend.expectGET('/katello/organizations/default_label?name=ChangedName').respond('changed_name');

        FormUtils.labelize(model, modelForm);
        $httpBackend.flush();

        expect(model.label).toBe('changed_name');
    });
});
