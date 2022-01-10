import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import { startCase, camelCase } from 'lodash';
import {
  BugIcon,
  SecurityIcon,
  EnhancementIcon,
} from '@patternfly/react-icons';
import {
  getContentViewVersions,
  getDebPackages,
  getDockerTags,
  getErrata,
  getFiles,
  getModuleStreams,
  getPackageGroups,
  getRepositories,
  getRPMPackages,
  getContent,
} from '../../ContentViewDetailActions';
import {
  selectCVVersions,
  selectCVVersionsStatus,
  selectDebPackages,
  selectDebPackagesStatus,
  selectDockerTags,
  selectDockerTagsStatus,
  selectFiles,
  selectFilesStatus,
  selectErrata,
  selectErrataStatus,
  selectModuleStreams,
  selectModuleStreamsStatus,
  selectRepositories,
  selectRepositoriesStatus,
  selectRPMPackageGroups,
  selectRPMPackageGroupsStatus,
  selectRPMPackages,
  selectRPMPackagesStatus,
  selectContent,
  selectContentStatus,
} from '../../ContentViewDetailSelectors';
import ContentViewVersionRepositoryCell from './ContentViewVersionRepositoryCell';
import ContentConfig from '../../../../Content/ContentConfig';

export const TableType = PropTypes.shape({
  name: PropTypes.string,
  route: PropTypes.string,
  getCountKey: PropTypes.func,
  repoType: PropTypes.string,
  responseSelector: PropTypes.func,
  statusSelector: PropTypes.func,
  autocompleteEndpoint: PropTypes.string,
  fetchItems: PropTypes.func,
  columnHeaders:
    PropTypes.arrayOf(PropTypes.shape({
      title: PropTypes.string,
      width: PropTypes.number,
      getProperty: PropTypes.func,
    })),
});

export default ({ cvId, versionId }) => [
  {
    name: __('Components'),
    route: 'components',
    getCountKey: item => item?.component_view_count,
    responseSelector: state => selectCVVersions(state, cvId),
    statusSelector: state => selectCVVersionsStatus(state, cvId),
    autocompleteEndpoint: '',
    fetchItems: params => getContentViewVersions(
      cvId,
      { composite_version_id: versionId, ...params, content_view_id: undefined },
    ),
    columnHeaders: [
      {
        title: __('Content View Name'),
        getProperty: item => (
          <a href={`${urlBuilder('content_views', '')}${item?.content_view_id}`}>
            {item?.content_view?.name}
          </a>),
      },
      { title: __('Version'), getProperty: item => item?.version },
      {
        title: __('Updated'),
        getProperty: item => item?.updated_at &&
          <LongDateTime date={item.updated_at} showRelativeTimeTooltip />,
      },
    ],
    disableSearch: true,
  },
  {
    name: __('Repositories'),
    route: 'repositories',
    getCountKey: item => item?.repositories?.length,
    responseSelector: state => selectRepositories(state),
    statusSelector: state => selectRepositoriesStatus(state),
    autocompleteEndpoint: `/repositories/auto_complete_search?archived=true&content_view_version_id=${versionId}`,
    fetchItems: params => getRepositories({
      content_view_version_id: versionId,
      archived: true,
      ...params,
    }),
    columnHeaders: [
      {
        title: __('Name'),
        getProperty: item => (
          <a href={urlBuilder(`products/${item?.product?.id}/repositories/${item?.id}`, '')}>
            {item?.name}
          </a>),
      },
      {
        title: __('Type'),
        getProperty: item => startCase(item?.content_type),
      },
      {
        title: __('Product'),
        getProperty: item => (
          <a href={urlBuilder(`products/${item?.product?.id}`, '')}>
            {item?.product?.name}
          </a>),
      },
      {
        title: __('Content'),
        getProperty: item => <ContentViewVersionRepositoryCell data={item} />,
      },
    ],
  },
  {
    name: __('RPM Packages'),
    route: 'rpmPackages',
    repoType: 'yum',
    getCountKey: item => item?.rpm_count,
    responseSelector: state => selectRPMPackages(state),
    statusSelector: state => selectRPMPackagesStatus(state),
    autocompleteEndpoint: `/packages/auto_complete_search?content_view_version_id=${versionId}`,
    fetchItems: params => getRPMPackages({ content_view_version_id: versionId, ...params }),
    columnHeaders: [
      {
        title: __('Name'),
        getProperty: item => (
          <a href={urlBuilder(`packages/${item?.id}`, '')}>
            {item?.nvrea}
          </a>),
      },
      { title: __('Version'), getProperty: item => item?.version },
      { title: __('Release'), getProperty: item => item?.release },
      { title: __('Arch'), getProperty: item => item?.arch },
    ],
  },
  {
    name: __('RPM Package Groups'),
    route: 'rpmPackageGroups',
    repoType: 'yum',
    getCountKey: item => item?.package_group_count,
    responseSelector: state => selectRPMPackageGroups(state),
    statusSelector: state => selectRPMPackageGroupsStatus(state),
    autocompleteEndpoint: `/package_groups/auto_complete_search?content_view_version_id=${versionId}`,
    fetchItems: params => getPackageGroups({ content_view_version_id: versionId, ...params }),
    columnHeaders: [
      { title: __('Name'), getProperty: item => item?.name },
      { title: __('Repository'), getProperty: item => item?.repository?.name },
    ],
  },
  {
    name: __('Files'),
    route: 'files',
    repoType: 'file',
    getCountKey: item => item?.file_count,
    responseSelector: state => selectFiles(state),
    statusSelector: state => selectFilesStatus(state),
    autocompleteEndpoint: `/files/auto_complete_search?content_view_version_id=${versionId}`,
    fetchItems: params => getFiles({ content_view_version_id: versionId, ...params }),
    columnHeaders: [
      {
        title: __('Name'),
        getProperty: item => (
          <a href={urlBuilder(`files/${item?.id}`, '')}>
            {item?.name}
          </a>),
      },
      { title: __('Path'), getProperty: item => item?.path },
    ],
  },
  {
    name: __('Errata'),
    route: 'errata',
    repoType: 'yum',
    getCountKey: item => item?.erratum_count,
    responseSelector: state => selectErrata(state),
    statusSelector: state => selectErrataStatus(state),
    autocompleteEndpoint: `/errata/auto_complete_search?content_view_version_id=${versionId}`,
    fetchItems: params => getErrata({ content_view_version_id: versionId, ...params }),
    columnHeaders: [
      {
        title: __('Errata ID'),
        getProperty: item => (
          <a href={urlBuilder(`errata/${item?.id}`, '')}>
            {item?.errata_id}
          </a>),
      },
      {
        title: __('Title'),
        getProperty: item => item?.name,
      },
      {
        title: __('Type'),
        getProperty: (item) => {
          const errataIcons = {
            security: SecurityIcon,
            bugfix: BugIcon,
            enhancement: EnhancementIcon,
            enhancements: EnhancementIcon,
          };
          const ErrataIcon = errataIcons[item?.type];
          if (!ErrataIcon) return startCase(item?.type);
          return <><ErrataIcon />{' '}{startCase(item?.type)}{item?.severity && ` - ${item.severity}`}</>;
        },
      },
      {
        title: __('Modular'),
        getProperty: (item) => {
          if (item?.module_streams?.length) return __('Yes');
          return __('No');
        },
      },
      {
        title: __('Applicable Content Hosts'),
        getProperty: item => item?.hosts_applicable_count,
        width: 25,
      },
      {
        title: __('Updated'),
        getProperty: item => item?.updated &&
          <LongDateTime date={item.updated} showRelativeTimeTooltip />,
      },
    ],
  },
  {
    name: __('Module Streams'),
    route: 'moduleStreams',
    repoType: 'yum',
    getCountKey: item => item?.module_stream_count,
    responseSelector: state => selectModuleStreams(state),
    statusSelector: state => selectModuleStreamsStatus(state),
    autocompleteEndpoint: `/module_streams/auto_complete_search?content_view_version_id=${versionId}`,
    fetchItems: params => getModuleStreams({ content_view_version_id: versionId, ...params }),
    columnHeaders: [
      {
        title: __('Name'),
        getProperty: item => (
          <a href={urlBuilder(`module_streams/${item?.id}`, '')}>
            {item?.name}
          </a>),
      },
      { title: __('Stream'), getProperty: item => item?.stream },
      { title: __('Version'), getProperty: item => item?.version },
      { title: __('Context'), getProperty: item => item?.context },
      { title: __('Arch'), getProperty: item => item?.arch },
    ],
  },
  {
    name: __('Deb Packages'),
    route: 'debPackages',
    repoType: 'deb',
    getCountKey: item => item?.deb_count,
    responseSelector: state => selectDebPackages(state),
    statusSelector: state => selectDebPackagesStatus(state),
    autocompleteEndpoint: `/debs/auto_complete_search?content_view_version_id=${versionId}`,
    fetchItems: params => getDebPackages({ content_view_version_id: versionId, ...params }),
    columnHeaders: [
      {
        title: __('Name'),
        getProperty: item => (
          <a href={urlBuilder(`debs/${item?.id}`, '')}>
            {item?.name}
          </a>),
      },
      { title: __('Version'), getProperty: item => item?.version },
      { title: __('Architecture'), getProperty: item => item?.architecture },
    ],
  },
  {
    name: __('Docker Tags'),
    route: 'dockerTags',
    repoType: 'docker',
    getCountKey: item => item?.docker_tag_count,
    responseSelector: state => selectDockerTags(state),
    statusSelector: state => selectDockerTagsStatus(state),
    autocompleteEndpoint: `/docker_tags/auto_complete_search?content_view_version_id=${versionId}`,
    fetchItems: params => getDockerTags({ content_view_version_id: versionId, ...params }),
    columnHeaders: [
      {
        title: __('Name'),
        getProperty: item => (
          <a href={urlBuilder(`docker_tags/${item?.id}`, '')}>
            {item?.name}
          </a>),
      },
      {
        title: __('Available Schema Versions'),
        getProperty: (item) => {
          if (item?.manifest_schema1) return __('Schema Version 1');
          return __('Schema Version 2');
        },
      },
      { title: __('Product Name'), getProperty: item => item?.product?.name },
    ],
  },
  ...ContentConfig.map(({
    names: { pluralTitle, pluralLabel, singularLabel },
    columnHeaders,
  }) => ({
    name: pluralTitle,
    route: camelCase(pluralLabel),
    repoType: singularLabel,
    getCountKey: item => item[`${singularLabel}_count`],
    responseSelector: state => selectContent(pluralLabel, state),
    statusSelector: state => selectContentStatus(pluralLabel, state),
    autocompleteEndpoint: `/${pluralLabel}/auto_complete_search?content_view_version_id=${versionId}`,
    fetchItems: params =>
      getContent(pluralLabel, { content_view_version_id: versionId, ...params }),
    columnHeaders,
  })),
];
