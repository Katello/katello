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
 **/

describe('Factory: Environment', function() {
    var $resource,
        Routes,
        environments;

    beforeEach(module('Bastion.environments', 'Bastion.utils'));

    beforeEach(module(function($provide) {
        environments = {
            results: [
                { name: 'Environment1', id: 1 },
                { name: 'Environment2', id: 2 }
            ],
            total: 10,
            subtotal: 5,
            limit: 5,
            offset: 0
        };

        Routes = {
            apiOrganizationEnvironmentsPath: function(organizationId) {}
        };

        $resource = function() {
            this.get = function(id) {
                return environments.results[0];
            };
            this.update = function(data) {
                environments.results[0] = data;
                return environments.results[0];
            };
            this.query = function() {
                return environments;
            };

            return this;
        };

        $provide.value('$resource', $resource);
        $provide.value('Routes', Routes);
        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function(_Environment_) {
        Environment = _Environment_;
    }));

    it('provides a way to get a collection of environments', function() {
        var environments = Environment.query();

        expect(environments.results.length).toBe(2);
        expect(environments.total).toBe(10);
        expect(environments.subtotal).toBe(5);
        expect(environments.offset).toBe(0);
    });

    it('provides a way to get a single environment', function() {
        var environment = Environment.get({ id: 1 });

        expect(environment).toBeDefined();
        expect(environment.name).toEqual('Environment1');
    });

    it('provides a way to update an environment', function() {
        var environment = Environment.update({ id: 1, name: 'NewEnvName' });

        expect(environment).toBeDefined();
        expect(environment.name).toEqual('NewEnvName');
    });
});

