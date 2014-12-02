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

describe('Factory: Erratum', function() {
    var Erratum, erratum;

    beforeEach(module('Bastion.errata'));

    beforeEach(module(function($provide) {
        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function(_Erratum_) {
        Erratum = _Erratum_;
    }));

    it("provides a way to update a content host", function() {
        var applicable_systems = [2, 3, 4],
            erratum = {
                id: 1,
                'systems_applicable': applicable_systems
            };

        $httpBackend.expectGET('/api/v2/errata/1').respond(erratum);

        Erratum.applicableContentHosts({id: 1}, function (result) {
            expect(result.results).toEqual(applicable_systems);
            expect(result.subtotal).toBe(3);
            expect(result.total).toBe(3);
        });
    });
});
