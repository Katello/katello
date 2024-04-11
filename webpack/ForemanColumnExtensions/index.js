/* eslint-disable no-param-reassign */
import React from 'react';
import {
  BugIcon,
  SecurityIcon,
  EnhancementIcon,
  PackageIcon,
} from '@patternfly/react-icons';
import { Link } from 'react-router-dom';
import { Flex, FlexItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import RelativeDateTime from 'foremanReact/components/common/dates/RelativeDateTime';

const hostsIndexColumnExtensions = [
  {
    columnName: 'rhel_lifecycle_status',
    title: __('RHEL Lifecycle status'),
    wrapper: (hostDetails) => {
      const rhelLifecycle = hostDetails?.rhel_lifecycle_status_label;
      return rhelLifecycle || '—';
    },
    weight: 2000,
    isSorted: true,
  },
  {
    columnName: 'installable_updates',
    title: __('Installable updates'),
    wrapper: (hostDetails) => {
      const errataCounts = hostDetails?.content_facet_attributes?.errata_counts;
      const registered = !!hostDetails?.subscription_facet_attributes?.uuid;
      const { security, bugfix, enhancement } = errataCounts ?? {};
      const upgradableRpmCount = hostDetails?.content_facet_attributes?.upgradable_package_count;
      if (!registered) return '—';
      const hostErrataUrl = type => `hosts/${hostDetails?.name}#/Content/errata?type=${type}&show=installable`;
      return (
        <Flex alignContent={{ default: 'alignContentSpaceBetween' }}>
          {security !== undefined &&
            <FlexItem>
              <SecurityIcon color="#0066cc" />
              <Link to={hostErrataUrl('security')}>{security}</Link>
            </FlexItem>
          }
          {bugfix !== undefined &&
            <FlexItem>
              <BugIcon color="#8bc1f7" />
              <Link to={hostErrataUrl('bugfix')}>{bugfix}</Link>
            </FlexItem>
          }
          {enhancement !== undefined &&
            <FlexItem>
              <EnhancementIcon color="#002f5d" />
              <Link to={hostErrataUrl('enhancement')}>{enhancement}</Link>
            </FlexItem>
          }
          {upgradableRpmCount !== undefined &&
            <FlexItem>
              <PackageIcon />
              <Link to={`hosts/${hostDetails?.name}#/Content/Packages?status=Upgradable`}>{upgradableRpmCount}</Link>
            </FlexItem>
          }
        </Flex>
      );
    },
    weight: 2100,
    isSorted: false,
  },
  {
    columnName: 'last_checkin',
    title: __('Last seen'),
    wrapper: (hostDetails) => {
      const lastCheckin =
        hostDetails?.subscription_facet_attributes?.last_checkin;
      return <RelativeDateTime defaultValue="—" date={lastCheckin} />;
    },
    weight: 2200,
    isSorted: true,
  },
  {
    columnName: 'lifecycle_environment',
    title: __('Lifecycle environment'),
    wrapper: (hostDetails) => {
      const lifecycleEnvironment =
        hostDetails?.content_facet_attributes?.lifecycle_environment?.name;
      return lifecycleEnvironment || '—';
    },
    weight: 2300,
    isSorted: true,
  },
  {
    columnName: 'content_view',
    title: __('Content view'),
    wrapper: (hostDetails) => {
      const contentView =
        hostDetails?.content_facet_attributes?.content_view?.name;
      return contentView || '—';
    },
    weight: 2400,
    isSorted: true,
  },
  {
    columnName: 'content_source',
    title: __('Content source'),
    wrapper: (hostDetails) => {
      const contentSource =
        hostDetails?.content_facet_attributes?.content_source_name;
      return contentSource || '—';
    },
    weight: 2500,
    isSorted: false,
  },
  {
    columnName: 'registered_at',
    title: __('Registered at'),
    wrapper: (hostDetails) => {
      const registeredAt = hostDetails?.subscription_facet_attributes?.registered_at;
      return <RelativeDateTime defaultValue="—" date={registeredAt} />;
    },
    weight: 2600,
    isSorted: true,
  },
];

hostsIndexColumnExtensions.forEach((column) => {
  column.tableName = 'hosts';
  column.categoryName = 'Content';
  column.categoryKey = 'content';
});

export default hostsIndexColumnExtensions;
