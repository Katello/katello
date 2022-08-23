import React, { useState } from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import { Link, useParams, useLocation } from 'react-router-dom';
import { capitalize, startCase } from 'lodash';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { Breadcrumb, BreadcrumbItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import {
  selectCVDetails, selectCVDetailStatus, selectCVFilterDetails, selectCVFilterDetailStatus,
  selectCVVersionDetails, selectCVVersionDetailsStatus,
} from '../Details/ContentViewDetailSelectors';

const CVBreadcrumb = () => {
  const { id } = useParams();
  const { hash } = useLocation();
  const splitHash = hash.split('/');
  const [recordId, setRecordId] = useState(null);
  const [recordModel, setRecordModel] = useState(null);
  const cvId = Number(id);
  const cvDetails = useSelector(state =>
    selectCVDetails(state, cvId), shallowEqual);
  const cvDetailsStatus = useSelector(state =>
    selectCVDetailStatus(state, cvId));
  const filterDetails = useSelector(state =>
    selectCVFilterDetails(state, cvId, recordId), shallowEqual);
  const filterDetailsStatus = useSelector(state =>
    selectCVFilterDetailStatus(state, cvId, recordId));
  const versionDetails = useSelector(state =>
    selectCVVersionDetails(state, recordId, cvId), shallowEqual);
  const versionDetailsStatus = useSelector(state =>
    selectCVVersionDetailsStatus(state, recordId, cvId));
  const [breadcrumbItems, setBreadcrumbItems] = useState({});

  useDeepCompareEffect(() => {
    setBreadcrumbItems({
      a_cv_index: { render: () => (<Link to="/content_views">{__('Content views')}</Link>) },
    });
    setRecordId(splitHash.length >= 3 ? splitHash[2] : null);
    setRecordModel(splitHash.length >= 3 ? splitHash[1] : null);
  }, [splitHash, setBreadcrumbItems, setRecordModel, setRecordId]);

  // Adds the 2nd level of breadcrumbs after content view details is available.
  // Adds a breadcrumb for CV name and the tab (version/repositories/details)
  useDeepCompareEffect(() => {
    if (cvDetails && cvDetailsStatus === STATUS.RESOLVED &&
      Object.keys(breadcrumbItems).length === 1) {
      const cvRecordCrumb = {
        [`b_${cvDetails?.name}`]: {
          render: () => (<Link to={`/content_views/${cvId}`}>{cvDetails?.name}</Link>),
        },
      };
      const tabName = splitHash[1];
      const tabRecordCrumb = {
        [`c_${tabName}`]: {
          render: () => (<Link to={`/content_views/${cvId}#/${tabName}`}>{capitalize(tabName)}</Link>),
        },
      };
      setBreadcrumbItems({ ...breadcrumbItems, ...cvRecordCrumb, ...tabRecordCrumb });
    }
  }, [splitHash, cvId, cvDetails, cvDetailsStatus, breadcrumbItems, setBreadcrumbItems]);

  // Adds the 3rd level of breadcrumbs when on Versions Details or Filter Details tabs.
  // Needs filter/version details to be available for forming this.
  useDeepCompareEffect(() => {
    if (Object.keys(breadcrumbItems).length === 3 && splitHash.length >= 3) {
      const tabName = splitHash[1];
      if (recordModel === 'filters') {
        if (filterDetails && filterDetailsStatus === STATUS.RESOLVED) {
          const { name } = filterDetails;
          const filterDetailCrumb = {
            [`d_${name}`]: {
              render: () => (<Link to={`/content_views/${cvId}#/${tabName}/${recordId}`}>{name}</Link>),
            },
          };
          setBreadcrumbItems({ ...breadcrumbItems, ...filterDetailCrumb });
        }
      } else if (recordModel === 'versions') {
        if (versionDetails && versionDetailsStatus === STATUS.RESOLVED) {
          const versionTabName = startCase(splitHash[3]);
          const { version } = versionDetails;
          const versionDetailCrumb = {
            [`e_${version}`]: {
              render: () => (<Link to={`/content_views/${cvId}#/${tabName}/${recordId}`}>{version}</Link>),
            },
          };
          const versionSecondaryTab = {
            [`f_${versionTabName}`]: {
              render: () => (
                <Link to={`/content_views/${cvId}#/${tabName}/${recordId}/${versionTabName}`}>
                  {capitalize(versionTabName)}
                </Link>
              ),
            },
          };
          setBreadcrumbItems({ ...breadcrumbItems, ...versionDetailCrumb, ...versionSecondaryTab });
        }
      }
    }
  }, [cvId, recordId, recordModel, splitHash, versionDetails, versionDetailsStatus,
    filterDetails, filterDetailsStatus, breadcrumbItems, setBreadcrumbItems]);

  return (
    <Breadcrumb ouiaId="cv-breadcrumb" className="margin-bottom-24">
      {
        Object.keys(breadcrumbItems)?.sort()?.map(key => (
          <BreadcrumbItem
            key={key}
            aria-label={key}
            render={breadcrumbItems[key].render}
          />))
      }
    </Breadcrumb>
  );
};

export default CVBreadcrumb;
