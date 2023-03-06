import URI from 'urijs';
import { useForemanVersion } from 'foremanReact/Root/Context/ForemanContext';
import { foremanUrl } from 'foremanReact/common/helpers';

// useKatelloDocUrl('Managing_Content, '#Products_and_Repositories_content-management') =>
// https://docs.theforeman.org/3.7/Managing_Content/index-katello.html#Products_and_Repositories_content-management
export const useKatelloDocUrl = (guide = 'Managing_Content', hash = '') => {
  // in dev you'll have to replace the Foreman version in the url with the latest published one
  const foremanVersion = useForemanVersion();
  const rootUrl = `https://docs.theforeman.org/${foremanVersion}/`;

  const section = `${guide}/index-katello.html${hash}`;

  const url = new URI({ path: '/links/manual', query: { root_url: rootUrl, section } });
  return foremanUrl(url.href());
};

export default useKatelloDocUrl;
