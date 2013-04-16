/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

angular.module('Katello').factory('Nutupane', ['$location', '$http', 'current_organization', function($location, $http, current_organization){
    var Nutupane = {};

    Nutupane.get = function(options){
        return $http.get(options.url, {
            params : {
                'organization_id':  current_organization,
                'search':           $location.search().search,
                'sort_by':          options.sort.by, 
                'sort_order':       options.sort.order, 
                'paged':            true,
                'offset':           options.offset
            }
        })
        .then(function(response){
            options.callback(options.transform(response.data));
        });
    };

    return Nutupane;
}]);
