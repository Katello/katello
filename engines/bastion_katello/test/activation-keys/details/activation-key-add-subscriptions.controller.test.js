describe('Controller: ActivationKeyAddSubscriptionsController', function() {
    var $scope,
        ActivationKey,
        SubscriptionsHelper,
        Nutupane,
        subscriptions;

    beforeEach(module('Bastion.activation-keys', 'Bastion.subscriptions', 'Bastion.test-mocks',
                      'activation-keys/details/views/activation-key-add-subscriptions.html'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
            this.setSearchKey = function() {}; 
        };
        ActivationKey = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location, $state, $injector) {
        $scope = $rootScope.$new();

        SubscriptionsHelper = $injector.get('SubscriptionsHelper')

        subscriptions = {
            "total": 9,
            "subtotal": 9,
            "offset": null,
            "limit": null,
            "search": "",
            "sort": {
                "by": "name",
                "order": "ASC"
            },
            "results": [
                        {
                            "organization": {"name": "Mega Corporation", "label": "megacorp"},
                            "id": "ff80808143f94b760143fcee78210166",
                            "description": "",
                            "name": "Point of Sale",
                            "start_date": "2014-02-04",
                            "end_date": "2044-01-28",
                            "available": -1,
                            "quantity": -1,
                            "consumed": 0,
                            "amount": null,
                            "account_number": null,
                            "contract_number": null,
                            "support_type": "",
                            "support_level": "",
                            "product_id": "1391517922933",
                            "arch": "ALL",
                            "virt_only": false,
                            "sockets": 0,
                            "cores": 0,
                            "ram": 0,
                            "instance_multiplier": null,
                            "stacking_id": "",
                            "multi_entitlement": false
                        },
                        {
                            "organization": {"name": "Mega Corporation", "label": "megacorp"},
                            "id": "ff80808143f94b760143fceb9aca014b",
                            "description": "RHEV",
                            "name": "Red Hat Enterprise Virtualization Offering, Premium (2-socket)",
                            "start_date": "2013-12-31",
                            "end_date": "2016-12-31",
                            "available": 1,
                            "quantity": 1,
                            "consumed": 0,
                            "amount": null,
                            "account_number": "5364043",
                            "contract_number": "10317431",
                            "support_type": "L1-L3",
                            "support_level": "Premium",
                            "product_id": "MCT2927F3",
                            "arch": "x86_64,ppc64,ia64,ppc,x86,s390,s390x",
                            "virt_only": false,
                            "sockets": 2,
                            "cores": 0,
                            "ram": 0,
                            "instance_multiplier": null,
                            "stacking_id": "MCT2927F3",
                            "multi_entitlement": true,
                            "provided_products": [
                                                  {"id": "ff80808143f94b760143fceb9acb015c", "name": "Red Hat Beta"},
                                                  {"id": "ff80808143f94b760143fceb9acb015d", "name": "Red Hat Enterprise Linux Server - Extended Update Support"},
                                                  {"id": "ff80808143f94b760143fceb9acb015e", "name": "Red Hat Software Collections (for RHEL Server)"},
                                                  {"id": "ff80808143f94b760143fceb9acb015f", "name": "Red Hat Enterprise Virtualization"},
                                                  {"id": "ff80808143f94b760143fceb9acb0160", "name": "Red Hat Enterprise Linux Server"},
                                                  {"id": "ff80808143f94b760143fceb9acb0161", "name": "Red Hat Software Collections Beta (for RHEL Server)"}
                                                  ]
                        },
                        {
                            "organization": { "name": "Mega Corporation",  "label": "megacorp"},
                            "id": "ff80808143f94b760143fceb9aa40134",
                            "description": "RHEV",
                            "name": "Red Hat Enterprise Virtualization Offering, Premium (2-socket)",
                            "start_date": "2013-12-31",
                            "end_date": "2016-12-31",
                            "available": 1,
                            "quantity": 1,
                            "consumed": 0,
                            "amount": null,
                            "account_number": "5364043",
                            "contract_number": "10317433",
                            "support_type": "L1-L3",
                            "support_level": "Premium",
                            "product_id": "MCT2927F3RN",
                            "arch": "x86_64,ppc64,ia64,ppc,s390,x86,s390x",
                            "virt_only": false,
                            "sockets": 2,
                            "cores": 0,
                            "ram": 0,
                            "instance_multiplier": null,
                            "stacking_id": "MCT2927F3",
                            "multi_entitlement": true,
                            "provided_products": [
                                                  {"id": "ff80808143f94b760143fceb9aa50145", "name": "Red Hat Beta"},
                                                  {"id": "ff80808143f94b760143fceb9aa50146", "name": "Red Hat Enterprise Linux Server - Extended Update Support"},
                                                  {"id": "ff80808143f94b760143fceb9aa50147", "name": "Red Hat Software Collections (for RHEL Server)"},
                                                  {"id": "ff80808143f94b760143fceb9aa50148", "name": "Red Hat Enterprise Virtualization"},
                                                  {"id": "ff80808143f94b760143fceb9aa50149", "name": "Red Hat Enterprise Linux Server"},
                                                  {"id": "ff80808143f94b760143fceb9aa5014a", "name": "Red Hat Software Collections Beta (for RHEL Server)"}
                                                  ]
                        },
                        {
                            "organization": {"name": "Mega Corporation", "label": "megacorp"},
                            "id": "ff80808143f94b760143fceb9a8a011d",
                            "description": "RHEV",
                            "name": "Red Hat Enterprise Virtualization Offering, Premium (2-socket)",
                            "start_date": "2012-12-31",
                            "end_date": "2015-12-31",
                            "available": 1,
                            "quantity": 1,
                            "consumed": 0,
                            "amount": null,
                            "account_number": "5364043",
                            "contract_number": "10300070",
                            "support_type": "L1-L3",
                            "support_level": "Premium",
                            "product_id": "MCT2927F3RN",
                            "arch": "x86_64,ppc64,ia64,ppc,s390,x86,s390x",
                            "virt_only": false,
                            "sockets": 2,
                            "cores": 0,
                            "ram": 0,
                            "instance_multiplier": null,
                            "stacking_id": "MCT2927F3",
                            "multi_entitlement": true,
                            "provided_products": [
                                                  {"id": "ff80808143f94b760143fceb9a8b012e", "name": "Red Hat Beta"},
                                                  {"id": "ff80808143f94b760143fceb9a8b012f", "name": "Red Hat Enterprise Linux Server - Extended Update Support"},
                                                  {"id": "ff80808143f94b760143fceb9a8b0130", "name": "Red Hat Software Collections (for RHEL Server)"},
                                                  {"id": "ff80808143f94b760143fceb9a8b0131", "name": "Red Hat Enterprise Virtualization"},
                                                  {"id": "ff80808143f94b760143fceb9a8b0132", "name": "Red Hat Enterprise Linux Server"},
                                                  {"id": "ff80808143f94b760143fceb9a8b0133", "name": "Red Hat Software Collections Beta (for RHEL Server)"}
                                                  ]
                        },
                        {
                            "organization": {"name": "Mega Corporation", "label": "megacorp"},
                            "id": "ff80808143f94b760143fceb9a720106",
                            "description": "RHEV",
                            "name": "Red Hat Enterprise Virtualization Offering, Premium (2-socket)",
                            "start_date": "2012-12-31",
                            "end_date": "2015-12-31",
                            "available": 1,
                            "quantity": 1,
                            "consumed": 0,
                            "amount": null,
                            "account_number": "5364043",
                            "contract_number": "10300053",
                            "support_type": "L1-L3",
                            "support_level": "Premium",
                            "product_id": "MCT2927F3",
                            "arch": "x86_64,ppc64,ia64,ppc,x86,s390,s390x",
                            "virt_only": false,
                            "sockets": 2,
                            "cores": 0,
                            "ram": 0,
                            "instance_multiplier": null,
                            "stacking_id": "MCT2927F3",
                            "multi_entitlement": true,
                            "provided_products": [
                                                  {"id": "ff80808143f94b760143fceb9a730117", "name": "Red Hat Beta"},
                                                  {"id": "ff80808143f94b760143fceb9a730118", "name": "Red Hat Enterprise Linux Server - Extended Update Support"},
                                                  {"id": "ff80808143f94b760143fceb9a730119", "name": "Red Hat Software Collections (for RHEL Server)"},
                                                  {"id": "ff80808143f94b760143fceb9a73011a", "name": "Red Hat Enterprise Virtualization"},
                                                  {"id": "ff80808143f94b760143fceb9a73011b", "name": "Red Hat Enterprise Linux Server"},
                                                  {"id": "ff80808143f94b760143fceb9a73011c", "name": "Red Hat Software Collections Beta (for RHEL Server)"}
                                                  ]
                        },
                        {
                            "organization": {"name": "Mega Corporation", "label": "megacorp"},
                            "id": "ff80808143f94b760143fceb9a5d00ed",
                            "description": "Red Hat Enterprise Linux",
                            "name": "Red Hat Enterprise Linux Server, Standard (Physical or Virtual Nodes)",
                            "start_date": "2013-12-31",
                            "end_date": "2014-12-31",
                            "available": 17,
                            "quantity": 20,
                            "consumed": 3,
                            "amount": null,
                            "account_number": "5364043",
                            "contract_number": "10317216",
                            "support_type": "L1-L3",
                            "support_level": "Standard",
                            "product_id": "RH00004",
                            "arch": "x86_64,ppc64,ia64,ppc,s390,x86,s390x",
                            "virt_only": false,
                            "sockets": 2,
                            "cores": 0,
                            "ram": 0,
                            "instance_multiplier": 2,
                            "stacking_id": "RH00004",
                            "multi_entitlement": true,
                            "provided_products": [
                                                  {"id": "ff80808143f94b760143fceb9a5e0101", "name": "Red Hat Beta"},
                                                  {"id": "ff80808143f94b760143fceb9a5e0102", "name": "Red Hat Enterprise Linux 7 Public Beta"},
                                                  {"id": "ff80808143f94b760143fceb9a5e0103", "name": "Red Hat Software Collections (for RHEL Server)"},
                                                  {"id": "ff80808143f94b760143fceb9a5e0104", "name": "Red Hat Enterprise Linux Server"},
                                                  {"id": "ff80808143f94b760143fceb9a5e0105", "name": "Red Hat Software Collections Beta (for RHEL Server)"}
                                                  ]
                        },
                        {
                            "organization": {"name": "Mega Corporation", "label": "megacorp"},
                            "id": "ff80808143f94b760143fceb9a0f00b8",
                            "description": "Red Hat Enterprise Linux",
                            "name": "Red Hat Enterprise Linux Server, Premium (8 sockets) (Up to 4 guests)",
                            "start_date": "2013-12-31",
                            "end_date": "2014-12-31",
                            "available": 4,
                            "quantity": 4,
                            "consumed": 0,
                            "amount": null,
                            "account_number": "5364043",
                            "contract_number": "10317242",
                            "support_type": "L1-L3",
                            "support_level": "PREMIUM",
                            "product_id": "RH0103708",
                            "arch": "x86_64,ppc64,ia64,ppc,s390,x86,s390x",
                            "virt_only": false,
                            "sockets": 8,
                            "cores": 0,
                            "ram": 0,
                            "instance_multiplier": null,
                            "stacking_id": "",
                            "multi_entitlement": false,
                            "provided_products": [
                                                  {"id": "ff80808143f94b760143fceb9a1000c8", "name": "Red Hat Beta"},
                                                  {"id": "ff80808143f94b760143fceb9a1000c9", "name": "Red Hat Enterprise Linux 7 Public Beta"},
                                                  {"id": "ff80808143f94b760143fceb9a1000ca", "name": "Red Hat Enterprise Linux Server"},
                                                  {"id": "ff80808143f94b760143fceb9a1000cb", "name": "Red Hat Software Collections Beta (for RHEL Server)"}
                                                  ]
                        },
                        {
                            "organization": {"name": "Mega Corporation", "label": "megacorp"},
                            "id": "ff80808143f94b760143fceb993300a4",
                            "description": "Red Hat Enterprise Linux",
                            "name": "Red Hat Enterprise Linux Server, Premium (8 sockets) (Up to 4 guests)",
                            "start_date": "2013-12-31",
                            "end_date": "2014-12-31",
                            "available": 3,
                            "quantity": 3,
                            "consumed": 0,
                            "amount": null,
                            "account_number": "5364043",
                            "contract_number": "10317242",
                            "support_type": "L1-L3",
                            "support_level": "PREMIUM",
                            "product_id": "RH0103708",
                            "arch": "x86_64,ppc64,ia64,ppc,s390,x86,s390x",
                            "virt_only": false,
                            "sockets": 8,
                            "cores": 0,
                            "ram": 0,
                            "instance_multiplier": null,
                            "stacking_id": "",
                            "multi_entitlement": false,
                            "provided_products": [
                                                  {"id": "ff80808143f94b760143fceb993a00b4", "name": "Red Hat Beta"},
                                                  {"id": "ff80808143f94b760143fceb993a00b5", "name": "Red Hat Enterprise Linux 7 Public Beta"},
                                                  {"id": "ff80808143f94b760143fceb993a00b6", "name": "Red Hat Enterprise Linux Server"},
                                                  {"id": "ff80808143f94b760143fceb993a00b7", "name": "Red Hat Software Collections Beta (for RHEL Server)"}
                                                  ]
                        }
                        ]
        };


        $controller('ActivationKeyAddSubscriptionsController', {
            $scope: $scope,
            $state: $state,
            $location: $location,
            translate: function() {},
            Nutupane: Nutupane,
            CurrentOrganization: function () {},
            Subscription: function () {},
            ActivationKey: ActivationKey,
            SubscriptionsHelper: SubscriptionsHelper
        });
    }));

    it('attaches the nutupane table to the scope', function () {
        expect($scope.table).toBeDefined();
    });

    it('groups subscriptions', function () {
        spyOn(SubscriptionsHelper, 'groupByProductName').and.callThrough();
        $scope.table.rows = subscriptions.results;
        $scope.$digest();
        expect(SubscriptionsHelper.groupByProductName).toHaveBeenCalled();
        expect($scope.groupedSubscriptions["Red Hat Enterprise Linux Server, Premium (8 sockets) (Up to 4 guests)"].length).toBe(2);
        expect($scope.groupedSubscriptions["Point of Sale"].length).toBe(1);
        expect($scope.groupedSubscriptions["Red Hat Enterprise Virtualization Offering, Premium (2-socket)"].length).toBe(4);
        expect($scope.groupedSubscriptions["Red Hat Enterprise Linux Server, Standard (Physical or Virtual Nodes)"].length).toBe(1);
    });

    it('gets amount selector values appropriately', function() {
        expect($scope.amountSelectorValues(subscriptions.results[0])).toEqual([-1]);
        expect($scope.amountSelectorValues(subscriptions.results[1])).toEqual([1]);
        expect($scope.amountSelectorValues(subscriptions.results[5])).toEqual([1, 2, 3, 4, 5, 20]);
        expect($scope.amountSelectorValues(subscriptions.results[6])).toEqual([1, 2, 3, 4]);
        expect($scope.amountSelectorValues(subscriptions.results[7])).toEqual([1, 2, 3]);
    });

});
