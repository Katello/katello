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

/**
 * @ngdoc module
 * @name  Katello.globals
 *
 * @description
 *   Module for storing Katello global variables and constants.
 */
angular.module('Katello.globals', []);

/**
 * @ngdoc value
 * @name  Katello.globals.value:CurrentOrganization
 *
 * @description
 *   Provides a value wrapper around the current_organization.
 */
angular.module('Katello.globals').value('CurrentOrganization', KT.current_organization);

/**
 * @ngdoc value
 * @name  Katello.globals.value:notices
 *
 * @description
 *   Provides a value wrapper around Katello's notices object.
 */
angular.module('Katello.globals').value('notices', notices);
