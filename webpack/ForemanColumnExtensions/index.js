/* eslint-disable no-param-reassign */
import React from 'react';
import PropTypes from 'prop-types';
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
  Icon,
  Popover,
  Badge,
  Button,
  DescriptionList,
  DescriptionListGroup,
  DescriptionListDescription as Dd,
  DescriptionListTerm as Dt,
  Text,
  TextVariants,
  Tooltip,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import RelativeDateTime from 'foremanReact/components/common/dates/RelativeDateTime';
import { TableText } from '@patternfly/react-table';
import { ContentViewEnvironmentDisplay } from '../components/extensions/HostDetails/Cards/ContentViewDetailsCard/ContentViewDetailsCard';
import RepoIcon from '../scenes/ContentViews/Details/Repositories/RepoIcon';
import FontAwesomeImageModeIcon from '../components/extensions/Hosts/FontAwesomeImageModeIcon';
import './index.scss';

const inactiveIconClass = 'pf-v5-u-color-200';

const ErrataCount = ({
  label, icon: CountIcon, count, activeClassName, activeColor, to,
}) => (
  <FlexItem>
    <Flex
      spaceItems={{ default: 'spaceItemsXs' }}
      alignItems={{ default: 'alignItemsCenter' }}
      flexWrap={{ default: 'nowrap' }}
    >
      <FlexItem>
        <Tooltip content={label}>
          <Icon
            isInline
            className={count > 0 ? activeClassName : inactiveIconClass}
            style={count > 0 && activeColor ? { color: activeColor } : undefined}
          >
            <CountIcon />
          </Icon>
        </Tooltip>
      </FlexItem>
      <FlexItem>
        <Link to={to}>{count}</Link>
      </FlexItem>
    </Flex>
  </FlexItem>
);

ErrataCount.propTypes = {
  label: PropTypes.string.isRequired,
  icon: PropTypes.elementType.isRequired,
  count: PropTypes.number,
  activeClassName: PropTypes.string,
  activeColor: PropTypes.string,
  to: PropTypes.string.isRequired,
};

ErrataCount.defaultProps = {
  count: 0,
  activeClassName: undefined,
  activeColor: undefined,
};

const hostsIndexColumnExtensions = [
  {
    columnName: 'bootc_booted_image',
    title: (
      // Text has no span variant. A heading here would widen the column.
      <span data-ouia-component-id="image-mode-column-title">{__('Type')}</span>
    ),
    headerTooltip: __('Image mode / package mode'),
    headerModifier: 'fitContent',
    className: 'hosts-index-type-column',
    wrapper: (hostDetails) => {
      const imageMode = hostDetails?.content_facet_attributes?.bootc_booted_image;
      const digest = hostDetails?.content_facet_attributes?.bootc_booted_digest;
      return imageMode ? (
        <Popover
          id="image-mode-tooltip"
          className="image-mode-tooltip"
          maxWidth="74rem"
          headerContent={hostDetails.display_name}
          bodyContent={
            <Flex direction={{ default: 'column' }}>
              <FlexItem>
                <Flex direction={{ default: 'row' }} alignItems={{ default: 'alignItemsCenter' }} spaceItems={{ default: 'spaceItemsSm' }}>
                  <FlexItem>
                    <FontAwesomeImageModeIcon />
                  </FlexItem>
                  <FlexItem>
                    <Text component={TextVariants.h4} ouiaId="image-mode-popover-h4">
                      {__('Image-mode host')}
                    </Text>
                  </FlexItem>
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
          <Button
            variant="plain"
            className="pf-m-no-padding"
            aria-label={__('Image mode')}
            ouiaId={`image-mode-popover-trigger-${hostDetails.id}`}
          >
            <FontAwesomeImageModeIcon margin="0" title={__('Image mode')} />
          </Button>
        </Popover>
      ) : (
        <Icon isInline className={inactiveIconClass}>
          <RepoIcon type="yum" customTooltip={__('Package mode')} />
        </Icon>
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
    cellModifier: 'nowrap',
    wrapper: (hostDetails) => {
      const errataCounts = hostDetails?.content_facet_attributes?.errata_counts;
      const registered = !!hostDetails?.subscription_facet_attributes?.uuid;
      const { security, bugfix, enhancement } = errataCounts ?? {};
      const upgradableRpmCount = hostDetails?.content_facet_attributes?.upgradable_package_count;
      const upgradableDebCount = hostDetails?.content_facet_attributes?.upgradable_deb_count;
      if (!registered) return '—';
      const hostErrataUrl = type => `hosts/${hostDetails?.name}#/Content/errata?type=${type}&show=installable`;
      return (
        <Flex
          spaceItems={{ default: 'spaceItemsSm' }}
          alignItems={{ default: 'alignItemsCenter' }}
          flexWrap={{ default: 'nowrap' }}
        >
          {security !== undefined &&
            <ErrataCount
              label={__('Security')}
              icon={SecurityIcon}
              count={security}
              activeClassName="pf-v5-u-primary-color-100"
              to={hostErrataUrl('security')}
            />
          }
          {bugfix !== undefined &&
            <ErrataCount
              label={__('Bugfix')}
              icon={BugIcon}
              count={bugfix}
              activeColor="var(--pf-v5-global--palette--blue-100)"
              to={hostErrataUrl('bugfix')}
            />
          }
          {enhancement !== undefined &&
            <ErrataCount
              label={__('Enhancement')}
              icon={EnhancementIcon}
              count={enhancement}
              activeColor="var(--pf-v5-global--palette--blue-500)"
              to={hostErrataUrl('enhancement')}
            />
          }
          {(upgradableRpmCount !== undefined || upgradableDebCount !== undefined) &&
            <ErrataCount
              label={__('Packages')}
              icon={PackageIcon}
              count={hostDetails?.operatingsystem_family === 'Debian' ? upgradableDebCount : upgradableRpmCount}
              activeClassName="pf-v5-u-primary-color-100"
              to={hostDetails?.operatingsystem_family === 'Debian'
                ? `hosts/${hostDetails?.name}#/Content/Debs?status=Upgradable`
                : `hosts/${hostDetails?.name}#/Content/Packages?status=Upgradable`}
            />
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
    columnName: 'content_view_environments',
    title: __('Content view environments'),
    cellModifier: 'truncate',
    wrapper: (hostDetails) => {
      const contentViewEnvironments =
        hostDetails?.content_facet_attributes?.content_view_environments ?? [];
      if (contentViewEnvironments.length === 0) return '—'; // don't show popover
      const labels = contentViewEnvironments.map(cvEnv => cvEnv.label).join(', ');
      return (
        <Flex className="pf-v5-u-min-width pf-v5-u-w-100" flexWrap={{ default: 'nowrap' }}>
          {contentViewEnvironments.length > 1 &&
            <FlexItem>
              <Badge isRead>{contentViewEnvironments.length}</Badge>
            </FlexItem>
          }
          <FlexItem className="pf-v5-u-min-width" flex={{ default: 'flex_1' }}>
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
              <Button variant="plain" className="pf-m-no-padding pf-v5-u-w-100 pf-v5-u-color-100 pf-v5-u-text-align-left" ouiaId="content-view-environments-button">
                <TableText className="hosts-index-truncated-text" wrapModifier="truncate">{labels}</TableText>
              </Button>
            </Popover>
          </FlexItem>
        </Flex>
      );
    },
    weight: 2290,
    isSorted: false,
  },
  {
    columnName: 'content_source',
    title: __('Content source'),
    cellModifier: 'breakWord',
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
  {
    columnName: 'host_collections',
    title: __('Host collections'),
    cellModifier: 'truncate',
    wrapper: (hostDetails) => {
      const hostCollections = hostDetails?.host_collections ?? [];
      if (hostCollections.length === 0) return '—';

      // Show count badge if more than one collection
      if (hostCollections.length > 1) {
        const labels = hostCollections.map(hc => hc.name).join(', ');
        return (
          <Flex className="pf-v5-u-min-width pf-v5-u-w-100" flexWrap={{ default: 'nowrap' }}>
            <FlexItem>
              <Badge isRead>{hostCollections.length}</Badge>
            </FlexItem>
            <FlexItem className="pf-v5-u-min-width" flex={{ default: 'flex_1' }}>
              <Popover
                id="host-collections-tooltip"
                className="host-collections-tooltip"
                maxWidth="34rem"
                headerContent={hostDetails.display_name}
                bodyContent={
                  <Flex direction={{ default: 'column' }}>
                    {hostCollections.map((hc, index) => (
                      <FlexItem key={hc.id}>
                        <Text component={TextVariants.p} ouiaId={`host-collection-name-${index}`}>
                          {hc.name}
                        </Text>
                      </FlexItem>
                    ))}
                  </Flex>
                }
              >
                <Button variant="plain" className="pf-m-no-padding pf-v5-u-w-100 pf-v5-u-color-100 pf-v5-u-text-align-left" ouiaId="host-collections-button">
                  <TableText className="hosts-index-truncated-text" wrapModifier="truncate">{labels}</TableText>
                </Button>
              </Popover>
            </FlexItem>
          </Flex>
        );
      }

      // Just show the name if only one collection
      return (
        <TableText wrapModifier="truncate">{hostCollections[0].name}</TableText>
      );
    },
    weight: 2700,
    isSorted: false,
  },
];

hostsIndexColumnExtensions.forEach((column) => {
  column.tableName = 'hosts';
  column.categoryName = 'Content';
  column.categoryKey = 'content';
});

export default hostsIndexColumnExtensions;
