import React, { useState } from 'react';
import { useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Alert, Switch, TextContent, Text,
  TextVariants, Form, FormGroup, TextArea, AlertActionCloseButton,
} from '@patternfly/react-core';
import { EnterpriseIcon, RegistryIcon } from '@patternfly/react-icons';
import EnvironmentPaths from '../components/EnvironmentPaths/EnvironmentPaths';
import ComponentEnvironments from '../Details/ComponentContentViews/ComponentEnvironments';
import './cvPublishForm.scss';
import WizardHeader from '../components/WizardHeader';
import { selectCVNeedsPublish } from '../Details/ContentViewDetailSelectors';
import { truncate } from '../../../utils/helpers';

const CVPublishForm = ({
  description,
  setDescription,
  details: {
    name, composite,
    next_version: nextVersion,
    needs_publish: needsPublish,
    duplicate_repositories_to_publish: duplicateRepos,
  },
  userCheckedItems,
  setUserCheckedItems,
  promote,
  setPromote,
  forcePromote,
}) => {
  const [alertDismissed, setAlertDismissed] = useState(false);
  const [needsPublishAlertDismissed, setNeedsPublishAlertDismissed] = useState(false);
  const [duplicateReposAlertDismissed, setDuplicateReposAlertDismissed] = useState(false);
  const needsPublishLocal = useSelector(state => selectCVNeedsPublish(state));

  const checkPromote = (checked) => {
    if (!checked) {
      setUserCheckedItems([]);
    }
    setPromote(checked);
  };
  return (
    <>
      <WizardHeader
        title={__('Publish')}
        description={
          <>
            {!needsPublishAlertDismissed &&
                !(needsPublish === null || needsPublish || needsPublishLocal) &&
                (
                <Alert
                  ouiaId="needs-publish-alert"
                  variant="info"
                  isInline
                  title={composite ?
                    __('No available component content view updates') :
                    __('No available repository or filter updates')}
                  actionClose={
                    <AlertActionCloseButton
                      onClose={() => setNeedsPublishAlertDismissed(true)}
                    />
            }
                  style={{ marginBottom: '24px' }}
                >
                  <TextContent>{__('Newly published version will be the same as the previous version.')}</TextContent>
                </Alert>)
            }
            {!duplicateReposAlertDismissed && composite &&
                (duplicateRepos !== null && duplicateRepos.length > 0) &&
                (
                <Alert
                  ouiaId="duplicate-repos-alert"
                  variant="info"
                  isInline
                  title={__('Duplicate repositories in content view versions')}
                  actionClose={
                    <AlertActionCloseButton
                      onClose={() => setDuplicateReposAlertDismissed(true)}
                    />
                        }
                  style={{ marginBottom: '24px' }}
                >
                  <TextContent>{__('Repositories common to the selected content view versions will merge, resulting in a composite content view that is a union of all content from each of the content view versions.')}</TextContent>
                </Alert>)
            }
            {__('A new version of ')}<b>{composite ? <RegistryIcon /> : <EnterpriseIcon />} {truncate(name)}</b>
            {__(' will be created and automatically promoted to the ' +
              'Library environment. You can promote to other environments as well. ')
            }
          </>
      }
      />
      <TextContent>
        <Text ouiaId="next-version-text" component={TextVariants.h3}>
          {__('Publish new version - ')}{nextVersion || '1.0'}
        </Text>
      </TextContent>
      <Form>
        <FormGroup label={__('Description')} fieldId="description">
          <TextArea
            isRequired
            type="text"
            id="description"
            aria-label="input_description"
            name="description"
            value={description}
            onChange={setDescription}
          />
        </FormGroup>
        <FormGroup label={__('Promote')} fieldId="promote">
          <Switch
            id="promote-switch"
            ouiaId="promote-switch"
            aria-label="promote-switch"
            isChecked={promote}
            onChange={checkPromote}
          />
        </FormGroup>
      </Form>
      {!alertDismissed && promote && forcePromote.length > 0 && (
        <Alert
          ouiaId="force-promotion-alert"
          variant="info"
          isInline
          title={__('Force promotion')}
          actionClose={<AlertActionCloseButton onClose={() => setAlertDismissed(true)} />}
        >
          <TextContent>
            {forcePromote.length > 1 ? __('Selected environments ') : __('Selected environment ')}
            <ComponentEnvironments environments={forcePromote} />
            {forcePromote.length > 1 ?
              __(' are out of the environment path order. The recommended practice is to promote to the next environment in the path.') :
              __(' is out of the environment path order. The recommended practice is to promote to the next environment in the path.')
            }
          </TextContent>
        </Alert>)}
      {promote &&
        <EnvironmentPaths
          userCheckedItems={userCheckedItems}
          setUserCheckedItems={setUserCheckedItems}
        />
      }
    </>
  );
};

CVPublishForm.propTypes = {
  description: PropTypes.string.isRequired,
  setDescription: PropTypes.func.isRequired,
  userCheckedItems: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  setUserCheckedItems: PropTypes.func.isRequired,
  promote: PropTypes.bool.isRequired,
  setPromote: PropTypes.func.isRequired,
  forcePromote: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  details: PropTypes.shape({
    id: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string,
    ]),
    name: PropTypes.string.isRequired,
    composite: PropTypes.bool.isRequired,
    next_version: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string,
    ]).isRequired,
    needs_publish: PropTypes.bool,
    duplicate_repositories_to_publish: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  }).isRequired,
};

export default CVPublishForm;
