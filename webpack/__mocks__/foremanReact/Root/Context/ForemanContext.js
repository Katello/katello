// eslint-disable-next-line import/prefer-default-export
export const useForemanSettings = () => ({ perPage: 20 });
export const useForemanVersion = () => 'nightly';
export const useForemanHostsPageUrl = () => '/new/hosts';
export const useForemanContext = () => ({
  metadata: {
    katello: {
      allow_multiple_content_views: true,
    },
  },
});
