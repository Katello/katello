import PropTypes from 'prop-types';
import {
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
} from '@patternfly/react-core';
import {
  Table,
  TableComposable,
  Tr,
} from '@patternfly/react-table';

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
    TableComposable,
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
