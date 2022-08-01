import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { useSelector } from 'react-redux';
import {
  Grid, GridItem, TextContent, Text, TextVariants, Tooltip,
  Select, SelectOption, SelectVariant, Flex, FlexItem,
} from '@patternfly/react-core';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import { selectCVDetails } from '../../ContentViewDetailSelectors';

const CVVersionCompareHeader = ({
  versionOne, versionTwo, cvId, setVersionOne, setVersionTwo,
}) => {
  const toolTipContent = 'Compare the content of any two versions of this content view.';
  const response = useSelector(state => selectCVDetails(state, cvId));
  const { versions } = response;
  const [isOpenSelectVersionOne, setIsOpenSelectVersionOne] = useState(false);
  const [isOpenSelectVersionTwo, setIsOpenSelectVersionTwo] = useState(false);
  const [isOpenSelectViewBy, setIsOpenSelectViewBy] = useState(false);

  const [selectedViewBy, setSelectedViewBy] = useState('Different');
  const viewBySelectionOptions = ['Different', 'Same'];

  const clearSelectionVersionOne = () => {
    setVersionOne(null);
    setIsOpenSelectVersionOne(false);
  };
  const clearSelectionVersionTwo = () => {
    setVersionTwo(null);
    setIsOpenSelectVersionTwo(false);
  };

  const clearSelectionViewBy = () => {
    setSelectedViewBy('');
    setIsOpenSelectViewBy(false);
  };
  const onSelectVersionOne = (_event, selection, isPlaceholder) => {
    if (isPlaceholder) {
      clearSelectionVersionOne();
    } else {
      setVersionOne(selection);
      setIsOpenSelectVersionOne(false);
    }
  };

  const onSelectVersionTwo = (_event, selection, isPlaceholder) => {
    if (isPlaceholder) {
      clearSelectionVersionTwo();
    } else {
      setVersionTwo(selection);
      setIsOpenSelectVersionTwo(false);
    }
  };

  const onSelectViewBy = (_event, selection, isPlaceholder) => {
    if (isPlaceholder) {
      clearSelectionViewBy();
    } else {
      setSelectedViewBy(selection);
      setIsOpenSelectViewBy(false);
    }
  };

  const filteredVersions = selectedVersion =>
    versions?.filter(result => Number(result.version) !== Number(selectedVersion));
  const filteredVersionsFirstSelect = versions?.filter(result =>
    Number(result.version) !== Number(versionTwo));
  const filteredVersionsSecondSelect = versions?.filter(result =>
    Number(result.version) !== Number(versionOne));
  const selectionOptionsViewBy = viewBySelectionOptions.map(option => (
    <SelectOption
      key={option}
      value={option}
    >
      {__(`${option}`)}
    </SelectOption>
  ));
  return (
    <Grid hasGutter style={{ margin: '0 24px' }}>
      <GridItem span={12} style={{ display: 'flex' }}>
        <TextContent>
          <Text ouiaId="cv-version-compare-button" component={TextVariants.h2}>{__('Compare')}</Text>
        </TextContent>
        <Tooltip aria="none" aria-live="polite" content={toolTipContent} style={{ marginLeft: 'auto' }}>
          <OutlinedQuestionCircleIcon />
        </Tooltip>
      </GridItem>
      <GridItem span={12}>
        <Flex>
          <FlexItem>
            <Flex direction={{ default: 'column' }}>
              <TextContent>
                <Text ouiaId="versions-to-compare-text" component={TextVariants.h4}>{__('Versions to compare')}</Text>
              </TextContent>
              <FlexItem>
                <Flex>
                  <FlexItem>
                    <Select
                      style={{ marginRight: '10px' }}
                      variant={SelectVariant.single}
                      placeholderText={__('Select an option')}
                      aria-label="Select version one"
                      ouiaId="select-version-one"
                      onToggle={setIsOpenSelectVersionOne}
                      onSelect={onSelectVersionOne}
                      selections={versionOne}
                      isOpen={isOpenSelectVersionOne}
                      isDisabled={!filteredVersionsFirstSelect?.length}
                    >
                      {filteredVersions(versionTwo)?.map(({ version }) => (
                        <SelectOption
                          key={version}
                          value={version}
                        >
                          {__('Version ')}{version}
                        </SelectOption>
                      ))}
                    </Select>
                  </FlexItem>
                  <FlexItem>
                    <TextContent style={{ margin: '10px' }}>
                      <Text ouiaId="to-text" component={TextVariants.h4}>{__('to')}</Text>
                    </TextContent>
                  </FlexItem>
                  <FlexItem>
                    <Select
                      variant={SelectVariant.single}
                      placeholderText="Select an option"
                      aria-label="Select version two"
                      ouiaId="select-version-two"
                      onToggle={setIsOpenSelectVersionTwo}
                      onSelect={onSelectVersionTwo}
                      selections={versionTwo}
                      isOpen={isOpenSelectVersionTwo}
                      isDisabled={!filteredVersionsSecondSelect?.length}
                    >
                      {filteredVersions(versionOne)?.map(({ version }) => (
                        <SelectOption
                          key={version}
                          value={version}
                        >
                          {__('Version ')}{version}
                        </SelectOption>
                      ))}
                    </Select>
                  </FlexItem>
                </Flex>
              </FlexItem>
            </Flex>
          </FlexItem >
          {false &&
            <FlexItem style={{ marginLeft: '60px' }}>
              <Flex direction={{ default: 'column' }}>
                <FlexItem>
                  <TextContent>
                    <Text component={TextVariants.h4}>{__('View by')}</Text>
                  </TextContent>
                </FlexItem>
                <FlexItem>
                  <Select
                    style={{ marginRight: '10px' }}
                    variant={SelectVariant.single}
                    placeholderText="Select an option"
                    aria-label="Select view by"
                    ouiaId="select-view-by"
                    onToggle={setIsOpenSelectViewBy}
                    onSelect={onSelectViewBy}
                    selections={selectedViewBy}
                    isOpen={isOpenSelectViewBy}
                    isDisabled={!(filteredVersionsFirstSelect?.length
                      && filteredVersionsSecondSelect?.length)}
                  >
                    {selectionOptionsViewBy}
                  </Select>
                </FlexItem>
              </Flex>
            </FlexItem >}
        </Flex >
      </GridItem>
    </Grid>
  );
};

CVVersionCompareHeader.propTypes = {
  versionOne: PropTypes.string.isRequired,
  versionTwo: PropTypes.string.isRequired,
  cvId: PropTypes.number.isRequired,
  setVersionOne: PropTypes.func.isRequired,
  setVersionTwo: PropTypes.func.isRequired,
};
export default CVVersionCompareHeader;
