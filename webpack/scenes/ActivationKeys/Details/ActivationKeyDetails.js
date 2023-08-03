import React, {
  useEffect,
  useState,
} from 'react';
import {
  useDispatch,
  useSelector,
} from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import {
  Title,
  TextContent,
  Text,
  TextVariants,
  Breadcrumb,
  BreadcrumbItem,
  Grid,
  GridItem,
  Label,
  Split,
  SplitItem,
  Flex,
  FlexItem,
  Panel,
} from '@patternfly/react-core';
import './ActivationKeyDetails.scss';
import EditModal from './components/EditModal';
import DeleteMenu from './components/DeleteMenu';
import { getActivationKey } from './ActivationKeyActions';
import DeleteModal from './components/DeleteModal';
import InactiveText from '../../ContentViews/components/InactiveText';

const ActivationKeyDetails = ({ match }) => {
  const dispatch = useDispatch();
  const akId = match?.params?.id;
  const akDetailsResponse = useSelector(state => selectAPIResponse(state, `ACTIVATION_KEY_${akId}`));
  const akDetails = propsToCamelCase(akDetailsResponse);
  const [isModalOpen, setModalOpen] = useState(false);

  useEffect(() => {
    if (akId) {
      dispatch(getActivationKey(akId));
    }
  }, [akId, dispatch]);

  const handleModalToggle = () => {
    setModalOpen(!isModalOpen);
  };

  return (
    <div >
      <Panel className="ak-details-header">
        <div className="breadcrumb-bar-pf4">
          <Breadcrumb ouiaId="ak-breadcrumbs" className="breadcrumb-display">
            <BreadcrumbItem className="breadcrumb-list" to="/activation_keys">
              {__('Activation keys')}
            </BreadcrumbItem>
            <BreadcrumbItem to="#" isActive>
              {akDetails.name}
            </BreadcrumbItem>
          </Breadcrumb>
        </div>
        <Grid>
          <GridItem span={8} className="ak-name-wrapper">
            <Flex justifyContent={{ default: 'jusifyContentSpaceBetween' }} alignItems={{ default: 'alignItemsCenter' }}>
              <FlexItem>
                <Title ouiaId="ak-title" headingLevel="h5" size="2xl" className="ak-name-truncate">
                  {akDetails.name}
                </Title>
              </FlexItem>
              <FlexItem>
                <Split hasGutter style={{ display: 'inline-flex' }}>
                  <SplitItem>
                    <Label>
                      {akDetails.usageCount ? akDetails.usageCount : 0}/{akDetails.unlimitedHosts ? __('Unlimited') : akDetails.maxHosts}
                    </Label>
                  </SplitItem>
                </Split>
              </FlexItem>
            </Flex>
          </GridItem>
          <GridItem offset={8} span={4}>
            <Flex>
              <FlexItem align={{ default: 'align-right' }}>
                <Split>
                  <SplitItem>
                    <EditModal akDetails={akDetails} akId={akId} />
                  </SplitItem>
                  <DeleteMenu handleModalToggle={handleModalToggle} akId={akId} />
                </Split>
              </FlexItem>
            </Flex>
          </GridItem>
        </Grid>
        <div className="ak-details-description">
          {akDetails.description ?
            <TextContent>
              <Text ouiaId="ak-description" component={TextVariants.p}>
                {akDetails.description}
              </Text>
            </TextContent> :
            <InactiveText text={__('No description provided')} />
          }
        </div>
      </Panel>
      <DeleteModal isModalOpen={isModalOpen} handleModalToggle={handleModalToggle} akId={akId} />
    </div>
  );
};

export default ActivationKeyDetails;


ActivationKeyDetails.propTypes = {
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string,
    }),
  }),
};

ActivationKeyDetails.defaultProps = {
  match: {},
};
