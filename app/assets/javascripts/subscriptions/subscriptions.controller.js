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
 * @ngdoc controller
 * @name  Katello.controller:SubscriptionsController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires $location
 * @requires $compile
 * @requires $filter
 * @requires $http
 * @requires $state
 * @requires Routes
 *
 * @description
 *   Provides the functionality specific to Subscriptions for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Katello').controller('SubscriptionsController',
    ['$scope', 'Nutupane', '$location', '$compile', '$filter', '$http', '$state', 'Routes',
    function($scope, Nutupane, $location, $compile, $filter, $http, $state, Routes) {

        var columns = [{
            id: 'name',
            display: 'Name',
            show: true
        },{
            id: 'consumed',
            display: 'Consumed',
            show: true
        },{
            id: 'limits',
            display: 'Limits',
            show: true
        },{
            id: 'type',
            display: 'Type',
            show: true
        },{
            id: 'start',
            display: 'Start Date',
            show: true
        },{
            id: 'end',
            display: 'End Date',
            show: true
        },{
            id: 'sla',
            display: 'Support',
            show: true
        },{
            id: 'contract',
            display: 'Contract',
            show: true
        },{
            id: 'account',
            display: 'Account',
            show: true
        }];

        var transform = function(data) {
            var rows = [];

            angular.forEach(data.subscriptions,
                function(subscription) {
                    var row = {
                        'row_id' : subscription.cp_id,
                        'show'  : true,
                        'cells': [{
                            display: $compile('<a ng-click="table.select_item(\'' + Routes.edit_subscription_path(subscription.cp_id) + '\',' + subscription.cp_id + ')">' + subscription.productName + '</a>')($scope),
                            column_id: 'name'
                        },{
                            display: (function() {
                                if (subscription.quantity < 0) {
                                    return 'Unlimited';
                                }
                                return subscription.consumed + ' of ' + subscription.quantity;
                            })(),
                            column_id: 'consumed'
                        },{
                            display: (function() {
                                var limits = [];
                                var value;

                                value = $filter('arrayObjectValue')(subscription.productAttributes, 'name', 'sockets', 'value');
                                if (value) {
                                    limits.push('Sockets: ' + value);
                                }
                                value = $filter('arrayObjectValue')(subscription.productAttributes, 'name', 'core', 'value');
                                if (value) {
                                    limits.push('Core: ' + value);
                                }
                                value = $filter('arrayObjectValue')(subscription.productAttributes, 'name', 'ram', 'value');
                                if (value) {
                                    limits.push('RAM: ' + value + ' GB');
                                }
                                return limits.join(', ');
                            })(),
                            column_id: 'limits'
                        },{
                            display: (function() {
                                var virt_only;

                                virt_only = $filter('arrayObjectValue')(subscription.attributes, 'name', 'virt_only', 'value');
                                if (virt_only) {
                                    return 'Virtual Only';
                                }
                                return 'Physical or Virtual';
                            })(),
                            column_id: 'type'
                        },{
                            display: $filter('date')(subscription.startDate, 'short'),
                            column_id: 'start'
                        },{
                            display: $filter('date')(subscription.endDate, 'short'),
                            column_id: 'end'
                        },{
                            display: $filter('arrayObjectValue')(subscription.productAttributes, 'name', 'support_level', 'value'),
                            column_id: 'sla'
                        },{
                            display: subscription.contractNumber,
                            column_id: 'contract'
                        },{
                            display: subscription.accountNumber,
                            column_id: 'account'
                        }]
                    };
                    rows.push(row);
                });

            return {
                rows    : rows,
                total   : data.total,
                subtotal: data.subtotal
            };
        };

        var nutupane                = new Nutupane();

        $scope.table                = nutupane.table;
        $scope.table.url            = Routes.api_subscriptions_path();
        $scope.table.transform      = transform;
        $scope.table.model          = 'Subscriptions';
        $scope.table.data.columns   = columns;
        $scope.table.active_item    = {};

        nutupane.setColumns([columns[0]]);

        nutupane.default_item_url = function(id) {
            return Routes.edit_subscription_path(id);
        };

        $scope.importManifest = function () {

            // Temporarily get the old import manifest UI
            // TODO REPLACE ME
            $http.get(KT.routes.new_subscription_path()).then(function (response) {
                var content = $('#nutupane-new-item .nutupane-pane-content'),
                    data = KT.common.getSearchParams() || {},
                    button = content.find('input[type|="submit"]');

                content.html(response.data);
                nutupane.table.setDetailsVisibility(false);
                nutupane.table.setNewItemVisibility(true);
            });
        };

        nutupane.get(function() {
            if ($location.search().item) {
                $scope.table.select_item(undefined, $location.search().item);
            }
        });

    }]

);
