import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { startCase } from 'lodash';
import { TimesIcon, CheckIcon, BugIcon, SecurityIcon, EnhancementIcon } from '@patternfly/react-icons';
import { Tooltip } from '@patternfly/react-core';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import {
  selectPackageGroupsComparison,
  selectPackageGroupsComparisonStatus,
  selectRPMPackagesComparison,
  selectRPMPackagesComparisonStatus,
  selectFilesComparison,
  selectFilesComparisonStatus,
  selectErrataComparison,
  selectErrataComparisonStatus,
  selectModuleStreamsComparison,
  selectModuleStreamsComparisonStatus,
  selectDebPackagesComparison,
  selectDebPackagesComparisonStatus,
  selectDockerTagsComparison,
  selectDockerTagsComparisonStatus,
} from '../../ContentViewDetailSelectors';
import {
  getPackageGroupsComparison,
  getRPMPackagesComparison,
  getFilesComparison,
  getErrataComparison,
  getModuleStreamsComparison,
  getDebPackagesComparison,
  getDockerTagsComparison,
} from '../../ContentViewDetailActions';

export const TableType = PropTypes.shape({
  name: PropTypes.string,
  getCountKey: PropTypes.func,
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

export default ({
  versionOne,
  versionTwo,
  versionOneId,
  versionTwoId,
}) => {
  const compareContent = (item, versionId) => {
    const {
      comparison,
    } = item;
    if (
      Number(comparison?.[0]) === Number(versionId)
      || Number(comparison?.[1]) === Number(versionId)) {
      return (
        <CheckIcon style={{ color: '#3E8635' }} />
      );
    }
    return (
      <TimesIcon style={{ color: '#6A6E73' }} />
    );
  };
  return ([
    {
      name: __('RPM packages'),
      getCountKey: (itemVersionOne, itemVersionTwo) =>
        itemVersionOne?.rpm_count || itemVersionTwo?.rpm_count,
      responseSelector: state => selectRPMPackagesComparison(state, versionOneId, versionTwoId),
      statusSelector: state => selectRPMPackagesComparisonStatus(state, versionOneId, versionTwoId),
      autocompleteEndpoint: '/packages/auto_complete_search',
      fetchItems: params => getRPMPackagesComparison(
        versionOneId,
        versionTwoId,
        params,
      ),
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
        { title: __('Epoch'), getProperty: item => item?.epoch },
        { title: __(`Version ${versionOne}`), getProperty: item => compareContent(item, versionOneId) },
        { title: __(`Version ${versionTwo}`), getProperty: item => compareContent(item, versionTwoId) },
      ],
    },
    {
      name: __('RPM package groups'),
      getCountKey: (itemVersionOne, itemVersionTwo) =>
        itemVersionOne?.package_group_count || itemVersionTwo?.package_group_count,
      responseSelector: state => selectPackageGroupsComparison(state, versionOneId, versionTwoId),
      statusSelector: state =>
        selectPackageGroupsComparisonStatus(state, versionOneId, versionTwoId),
      autocompleteEndpoint: '/package_groups/auto_complete_search',
      fetchItems: params => getPackageGroupsComparison(versionOneId, versionTwoId, params),
      columnHeaders: [
        { title: __('Name'), getProperty: item => item?.name },
        { title: __('Repository'), getProperty: item => item?.repository?.name },
        { title: __(`Version ${versionOne}`), getProperty: item => compareContent(item, versionOneId) },
        { title: __(`Version ${versionTwo}`), getProperty: item => compareContent(item, versionTwoId) },
      ],
    },
    {
      name: __('Files'),
      getCountKey: (itemVersionOne, itemVersionTwo) =>
        itemVersionOne?.file_count || itemVersionTwo?.file_count,
      responseSelector: state => selectFilesComparison(state, versionOneId, versionTwoId),
      statusSelector: state => selectFilesComparisonStatus(state, versionOneId, versionTwoId),
      autocompleteEndpoint: '/files/auto_complete_search',
      fetchItems: params => getFilesComparison(versionOneId, versionTwoId, params),
      columnHeaders: [
        {
          title: __('Name'),
          getProperty: item => (
            <a href={urlBuilder(`files/${item?.id}`, '')}>
              {item?.name}
            </a>),
        },
        { title: __('Path'), getProperty: item => item?.path },
        { title: __(`Version ${versionOne}`), getProperty: item => compareContent(item, versionOneId) },
        { title: __(`Version ${versionTwo}`), getProperty: item => compareContent(item, versionTwoId) },
      ],
    },
    {
      name: __('Errata'),
      getCountKey: (itemVersionOne, itemVersionTwo) =>
        itemVersionOne?.erratum_count || itemVersionTwo?.erratum_count,
      responseSelector: state => selectErrataComparison(state, versionOneId, versionTwoId),
      statusSelector: state => selectErrataComparisonStatus(state, versionOneId, versionTwoId),
      autocompleteEndpoint: '/errata/auto_complete_search',
      fetchItems: params => getErrataComparison(versionOneId, versionTwoId, params),
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
            const itemType = startCase(item?.type);
            if (!ErrataIcon) return itemType;
            return <><Tooltip content={itemType} ><ErrataIcon style={{ marginRight: '4px' }} /></Tooltip>{itemType}{item?.severity !== 'None' && ` - ${item.severity}`}</>;
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
        { title: __(`Version ${versionOne}`), getProperty: item => compareContent(item, versionOneId) },
        { title: __(`Version ${versionTwo}`), getProperty: item => compareContent(item, versionTwoId) },
      ],
    },
    {
      name: __('Module streams'),
      getCountKey: (itemVersionOne, itemVersionTwo) =>
        itemVersionOne?.module_stream_count || itemVersionTwo?.module_stream_count,
      responseSelector: state => selectModuleStreamsComparison(state, versionOneId, versionTwoId),
      statusSelector: state =>
        selectModuleStreamsComparisonStatus(state, versionOneId, versionTwoId),
      autocompleteEndpoint: '/module_streams/auto_complete_search',
      fetchItems: params => getModuleStreamsComparison(versionOneId, versionTwoId, params),
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
        { title: __(`Version ${versionOne}`), getProperty: item => compareContent(item, versionOneId) },
        { title: __(`Version ${versionTwo}`), getProperty: item => compareContent(item, versionTwoId) },
      ],
    },
    {
      name: __('Deb packages'),
      getCountKey: (itemVersionOne, itemVersionTwo) =>
        itemVersionOne?.deb_count || itemVersionTwo?.deb_count,
      responseSelector: state => selectDebPackagesComparison(state, versionOneId, versionTwoId),
      statusSelector: state => selectDebPackagesComparisonStatus(state, versionOneId, versionTwoId),
      autocompleteEndpoint: '/debs/auto_complete_search',
      fetchItems: params => getDebPackagesComparison(versionOneId, versionTwoId, params),
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
        { title: __(`Version ${versionOne}`), getProperty: item => compareContent(item, versionOneId) },
        { title: __(`Version ${versionTwo}`), getProperty: item => compareContent(item, versionTwoId) },
      ],
    },
    {
      name: __('Container tags'),
      getCountKey: (itemVersionOne, itemVersionTwo) =>
        itemVersionOne?.docker_tag_count || itemVersionTwo?.docker_tag_count,
      responseSelector: state => selectDockerTagsComparison(state, versionOneId, versionTwoId),
      statusSelector: state => selectDockerTagsComparisonStatus(state, versionOneId, versionTwoId),
      autocompleteEndpoint: '/docker_tags/auto_complete_search',
      fetchItems: params => getDockerTagsComparison(versionOneId, versionTwoId, params),
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
        { title: __(`Version ${versionOne}`), getProperty: item => compareContent(item, versionOneId) },
        { title: __(`Version ${versionTwo}`), getProperty: item => compareContent(item, versionTwoId) },
      ],
    },
  ]);
};
