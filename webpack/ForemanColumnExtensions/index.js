/* eslint-disable no-param-reassign */
import React from 'react';
import {
  BugIcon,
  SecurityIcon,
  EnhancementIcon,
  PackageIcon,
} from '@patternfly/react-icons';
import { Link } from 'react-router-dom';
import {
  Flex,
  FlexItem,
  Popover,
  Badge,
  DescriptionList,
  DescriptionListGroup,
  DescriptionListDescription as Dd,
  DescriptionListTerm as Dt,
  Text,
  TextVariants,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import RelativeDateTime from 'foremanReact/components/common/dates/RelativeDateTime';
import { ContentViewEnvironmentDisplay } from '../components/extensions/HostDetails/Cards/ContentViewDetailsCard/ContentViewDetailsCard';
import { truncate } from '../utils/helpers';
import RepoIcon from '../scenes/ContentViews/Details/Repositories/RepoIcon';
import FontAwesomeImageModeIcon from '../components/extensions/Hosts/FontAwesomeImageModeIcon';
import './index.scss';

const hostsIndexColumnExtensions = [
  {
    columnName: 'bootc_booted_image',
    title: (
      <Text title={__('Image mode / package mode')} ouiaId="image-mode-column-title" className="pf-c-table__text">{__('Type')}</Text>
    ),
    wrapper: (hostDetails) => {
      const imageMode = hostDetails?.content_facet_attributes?.bootc_booted_image;
      const digest = hostDetails?.content_facet_attributes?.bootc_booted_digest;
      return (
        <span className={imageMode ? 'image-mode-column-td-icon' : 'package-mode-column-td-icon'}>
          {imageMode ?
            <Popover
              id="image-mode-tooltip"
              className="image-mode-tooltip"
              maxWidth="74rem"
              headerContent={hostDetails.display_name}
              bodyContent={
                <Flex direction={{ default: 'column' }}>
                  <FlexItem>
                    <Flex direction={{ default: 'row' }} alignItems={{ default: 'alignItemsCenter' }}>
                      <FlexItem>
                        <FontAwesomeImageModeIcon />
                      </FlexItem>
                      <Text ouiaId="image-mode-popover-h4" component={TextVariants.h4}>{__('Image-mode host')}</Text>
                    </Flex>
                  </FlexItem>
                  <DescriptionList isCompact isHorizontal>
                    <DescriptionListGroup>
                      <Dt>{__('Running image')}</Dt>
                      <Dd>{hostDetails.content_facet_attributes.bootc_booted_image}</Dd>
                    </DescriptionListGroup>
                    <DescriptionListGroup>
                      <Dt>{__('Digest')}</Dt>
                      <Dd>{digest}</Dd>
                    </DescriptionListGroup>
                  </DescriptionList>
                </Flex>
              }
            >
              <FontAwesomeImageModeIcon title={__('Image mode')} />
            </Popover>
            : <span style={{ color: 'var(--pf-global--palette--black-600)' }}><RepoIcon type="yum" customTooltip={__('Package mode')} /></span>
          }
        </span>
      );
    },
    weight: 35, // between power status (0) and name (50)
    isSorted: true,
  },
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
      const upgradableDebCount = hostDetails?.content_facet_attributes?.upgradable_deb_count;
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
          {(upgradableRpmCount !== undefined || upgradableDebCount !== undefined) &&
            <FlexItem>
              <PackageIcon />
              { hostDetails?.operatingsystem_family === 'Debian' ?
                <Link to={`hosts/${hostDetails?.name}#/Content/Debs?status=Upgradable`}>{upgradableDebCount}</Link>
                :
                <Link to={`hosts/${hostDetails?.name}#/Content/Packages?status=Upgradable`}>{upgradableRpmCount}</Link>
              }
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
    columnName: 'content_view_environments',
    title: __('Content view environments'),
    wrapper: (hostDetails) => {
      const contentViewEnvironments =
        hostDetails?.content_facet_attributes?.content_view_environments ?? [];
      if (contentViewEnvironments.length === 0) return '—'; // don't show popover
      return (
        <Flex>
          {contentViewEnvironments.length > 1 &&
            <FlexItem>
              <Badge isRead>{contentViewEnvironments.length}</Badge>
            </FlexItem>
          }
          <Popover
            id="content-view-environments-tooltip"
            className="content-view-environments-tooltip"
            maxWidth="34rem"
            headerContent={hostDetails.display_name}
            bodyContent={
              <Flex direction={{ default: 'column' }}>
                {contentViewEnvironments.map(env => (
                  <ContentViewEnvironmentDisplay
                    key={`${env.lifecycle_environment.name}-${env.content_view.name}`}
                    contentView={env.content_view}
                    lifecycleEnvironment={env.lifecycle_environment}
                  />
                ))}
              </Flex>
            }
          >
            <FlexItem>
              {truncate(contentViewEnvironments.map(cve => cve.label).join(', '), 35)}
            </FlexItem>
          </Popover>
        </Flex>
      );
    },
    weight: 2290,
    isSorted: false,
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
