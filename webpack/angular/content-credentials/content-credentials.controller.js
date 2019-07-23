export default ['$scope', '$location', 'Nutupane', 'ContentCredential', 'CurrentOrganization',
  function ($scope, $location, Nutupane, ContentCredential, CurrentOrganization) {
    var params = {
      'organization_id': CurrentOrganization,
      'search': $location.search().search || '',
      'sort_by': 'name',
      'sort_order': 'ASC',
      'paged': true
    };

    var nutupane = new Nutupane(ContentCredential, params);
    $scope.controllerName = 'katello_gpg_keys';
    $scope.table = nutupane.table;
    $scope.panel = { loading: false };
    $scope.removeRow = nutupane.removeRow;
  }
];
