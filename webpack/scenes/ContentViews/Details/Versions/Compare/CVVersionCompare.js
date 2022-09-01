import React, { useState, useEffect, useCallback } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { Tab, Tabs, TabTitleText } from '@patternfly/react-core';
import CVVersionCompareHeader from './CVVersionCompareHeader';
import { selectCVDetails, selectCVVersionDetails, selectCVVersionDetailsStatus } from '../../ContentViewDetailSelectors';
import getCVVersionCompareTableConfigs from './CVVersionCompareConfig';
import CVVersionCompareTable from './CVVersionCompareTable';
import getContentViewDetails, { getContentViewVersionDetails } from '../../ContentViewDetailActions';
import Loading from '../../../../../components/Loading';
import './CVVersionCompare.scss';

const CVVersionCompare = ({
  cvId,
  versionIds,
  versionLabels,
}) => {
  const dispatch = useDispatch();
  const { versionOneId: initialVersionOneId, versionTwoId: initialVersionTwoId } = versionIds;
  const { versionOneLabel: initialVersionOne, versionTwoLabel: initialVersionTwo } = versionLabels;
  const { versions: cvDetails } = useSelector(state => selectCVDetails(state, cvId));
  const [versionOne, setVersionOne] = useState(initialVersionOne);
  const [versionTwo, setVersionTwo] = useState(initialVersionTwo);
  const getIdFromVersion = useCallback(version => (cvDetails?.find(result =>
    Number(result.version) === Number(version))?.id), [cvDetails]);

  const versionOneDetails = useSelector(state =>
    selectCVVersionDetails(state, String(getIdFromVersion(versionOne)
      ?? initialVersionOneId), cvId));
  const versionTwoDetails = useSelector(state =>
    selectCVVersionDetails(state, String(getIdFromVersion(versionTwo)
      ?? initialVersionTwoId), cvId));

  const [selectedViewBy, setSelectedViewBy] = useState('All');
  const tableConfigs = getCVVersionCompareTableConfigs({
    versionOne,
    versionTwo,
    versionOneId: String(getIdFromVersion(versionOne)),
    versionTwoId: String(getIdFromVersion(versionTwo)),
    viewBy: selectedViewBy.toLowerCase(),
  });

  const filteredTableConfigs = tableConfigs.filter(({ getCountKey }) =>
    !!getCountKey(versionOneDetails, versionTwoDetails));
  const versionOneDetailsStatus = useSelector(state =>
    selectCVVersionDetailsStatus(state, String(getIdFromVersion(versionOne)
      ?? initialVersionOneId), cvId));
  const versionTwoDetailsStatus = useSelector(state =>
    selectCVVersionDetailsStatus(state, String(getIdFromVersion(versionTwo)
      ?? initialVersionTwoId), cvId));

  const [currentActiveTab, setCurrentActiveTab] = useState(__('Repositories'));
  const onSelect = (_e, eventKey) => {
    // This prevents needless pushing on repeated clicks of a tab
    if (currentActiveTab !== eventKey) {
      setCurrentActiveTab(eventKey);
    }
  };
  const activeTableConfig = filteredTableConfigs.find(config =>
    String(currentActiveTab) === config.name);
  const showTabs = filteredTableConfigs.length > 0;
  const showCompareTable = !(versionOneDetailsStatus === STATUS.PENDING
    ||
    versionTwoDetailsStatus === STATUS.PENDING) && versionOne && versionTwo;

  useEffect(() => {
    if (!cvDetails) {
      dispatch(getContentViewDetails(cvId));
    }
  }, [dispatch, cvDetails, cvId]);

  useEffect(() => {
    if (cvDetails) {
      dispatch(getContentViewVersionDetails(String(getIdFromVersion(versionOne)
        ?? initialVersionOneId), cvId));
      dispatch(getContentViewVersionDetails(String(getIdFromVersion(versionTwo)
        ?? initialVersionTwoId), cvId));
    }
  }, [dispatch, versionOne, versionTwo, cvId, getIdFromVersion, cvDetails,
    initialVersionOneId, initialVersionTwoId]);

  return (
    <>
      <CVVersionCompareHeader
        versionOne={versionOne}
        versionTwo={versionTwo}
        cvId={cvId}
        setVersionOne={setVersionOne}
        setVersionTwo={setVersionTwo}
        selectedViewBy={selectedViewBy}
        setSelectedViewBy={setSelectedViewBy}
      />
      {showTabs && (
        (showCompareTable &&
          <div className="grid-with-top-border">
            <Tabs
              isVertical
              activeKey={currentActiveTab}
              onSelect={onSelect}
              ouiaId="cv-version-compare-tabs"
            >
              {filteredTableConfigs.map((config) => {
                const { name } = config;
                return (
                  <Tab
                    key={name}
                    eventKey={name}
                    title={
                      <>
                        <TabTitleText>{name}</TabTitleText>
                      </>}
                  />
                );
              })}
            </Tabs>
            <div className="compare-table-container">
              <CVVersionCompareTable
                tableConfig={activeTableConfig}
                versionOne={versionOne}
                versionTwo={versionTwo}
                currentActiveKey={currentActiveTab}
                selectedViewBy={selectedViewBy}
              />
            </div>
          </div >) || <Loading />)
      }
    </>
  );
};
CVVersionCompare.propTypes = {
  cvId: PropTypes.number.isRequired,
  versionIds: PropTypes.shape({
    versionOneId: PropTypes.string,
    versionTwoId: PropTypes.string,
  }).isRequired,
  versionLabels: PropTypes.shape({
    versionOneLabel: PropTypes.string,
    versionTwoLabel: PropTypes.string,
  }).isRequired,
};
export default CVVersionCompare;
