import PropTypes from 'prop-types';
import {
  Alert,
  Breadcrumb,
  Button,
  Card,
  Checkbox,
  Chip,
  ChipGroup,
  FormSelect,
  Menu,
  Modal,
  ModalContent,
  Nav,
  NavExpandable,
  NavItem,
  Pagination,
  Radio,
  Switch,
  TabButton,
  TabContent,
  Tabs,
  Text,
  TextInput,
  Title,
  Toolbar,
} from '@patternfly/react-core';
import {
  ContextSelector,
  Dropdown,
  DropdownItem,
  DropdownSeparator,
  DropdownToggle,
  DropdownToggleCheckbox,
  OptionsMenu,
  Select,
} from '@patternfly/react-core/deprecated';
import {
  Tr,
} from '@patternfly/react-table';
import {
  Table as TableDeprecated,
  Table,
} from '@patternfly/react-table/deprecated';

const checkForOuiaIds = () => {
  const ouiaSupportedPFComponents = [
    Alert,
    Breadcrumb,
    Button,
    Card,
    Checkbox,
    Chip,
    ChipGroup,
    ContextSelector,
    Dropdown,
    DropdownItem,
    DropdownSeparator,
    DropdownToggle,
    DropdownToggleCheckbox,
    FormSelect,
    Menu,
    Modal,
    ModalContent,
    Nav,
    NavExpandable,
    NavItem,
    OptionsMenu,
    Pagination,
    Radio,
    Select,
    Switch,
    TabButton,
    TabContent,
    Tabs,
    Text,
    TextInput,
    Title,
    Toolbar,
    Table,
    TableDeprecated,
    Tr,
  ];
  beforeEach(() => {
    // eslint-disable-next-line no-restricted-syntax
    for (const Component of ouiaSupportedPFComponents) {
      // eslint-disable-next-line no-continue
      if (!Component) continue;
      Component.propTypes = {
        ...Component.propTypes,
        ouiaId: PropTypes.string.isRequired,
      };
    }
  });
};

export default checkForOuiaIds;
