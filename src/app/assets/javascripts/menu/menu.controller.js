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
**/

'use strict';

Katello.controller('MenuController', ['$scope', '$sanitize', function($scope, $sanitize){

    $scope.menu = KT.main_menu;
    $scope.user_menu = KT.user_menu;
    $scope.admin_menu = KT.admin_menu;
    $scope.notices = KT.notices;

    if( $('body').attr('id') === 'systems' ){
        $scope.menu.active_item = KT.main_menu['items'][2];
        $scope.menu.active_item.active = true;
    } else if( $('body').attr('id') === 'contents' || $('body').attr('id') === 'subscriptions' ){
        $scope.menu.active_item = KT.main_menu['items'][1];
        $scope.menu.active_item.active = true;
    } else if( $('body').attr('id') === 'operations' ){
        $scope.admin_menu.active_item = KT.admin_menu['items'][0];
        $scope.admin_menu.active_item.active = true;
    } else {
        $scope.menu.active_item = KT.main_menu['items'][0];
        $scope.menu.active_item.active = true;
    }


}]);
