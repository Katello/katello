export default ['$resource', function ($resource) {

  return function (url, paramDefaults, actions) {
      var defaultActions;
      defaultActions = {
          queryPaged: {method: 'GET', isArray: false},
          queryUnpaged: {method: 'GET', isArray: false, params: {'full_result': true}}
      };

      actions = angular.extend({}, defaultActions, actions);

      return $resource(url, paramDefaults, actions);
  };

}]