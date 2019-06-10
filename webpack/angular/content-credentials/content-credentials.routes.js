import ContentCredentialsController from './content-credentials.controller';

routes.$inject = ['$stateProvider'];

export default function routes($stateProvider) {
  $stateProvider.state('content-credentials', {
      url: '/content_credentials2',
      permission: 'view_content_credentials',
      controller: ContentCredentialsController,
      template: require('./views/content-credentials.html'),
      ncyBreadcrumb: {
          label: "{{ 'Content Credential' }}"
      }
  })
}