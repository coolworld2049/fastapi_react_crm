import {
  BooleanField,
  BooleanInput,
  Create,
  Datagrid,
  Edit,
  EmailField,
  List,
  SimpleForm,
  TextField,
  TextInput,
  PasswordInput,
  ChipField,
  AutocompleteInput,
  ReferenceInput,
  FilterLiveSearch,
  required,
  NumberInput,
  SimpleShowLayout,
} from "react-admin";
import { user_sx } from "../../components/commonStyles";
import PublicIcon from "@mui/icons-material/Public";
import PublicOffIcon from "@mui/icons-material/PublicOff";

export const UserRoleInput = (props: any) => (
  <ReferenceInput {...props} source="role" reference="classifiers/user_role">
    <AutocompleteInput {...props} source="id" optionText="name" label="Role" />
  </ReferenceInput>
);

const UserPanel = (props: any) => (
  <SimpleShowLayout>
    <TextField source="username" />
    <TextField source="full_name" emptyText={"not set"} />
    <TextField source="age" emptyText={"not set"} />
    <TextField source="phone" emptyText={"not set"} />
    <BooleanField
      source="is_active"
      TrueIcon={PublicIcon}
      FalseIcon={PublicOffIcon}
      label={"Online"}
    />
  </SimpleShowLayout>
);

export const UserList = (props: any) => {
  const userFilters = [
    <FilterLiveSearch source="email" label={"Full Name"} />,
    <FilterLiveSearch source="username" label={"Username"} />,
    <FilterLiveSearch source="phone" label={"Phone"} />,
    <FilterLiveSearch source="email" label={"Email"} />,
    <UserRoleInput />,
  ];
  return (
    <List {...props} filters={userFilters}>
      <Datagrid
        rowClick="edit"
        bulkActionButtons={false}
        expand={UserPanel}
        expandSingle={true}
      >
        <EmailField source="email" />
        <ChipField source="role" />
      </Datagrid>
    </List>
  );
};

export const UserEdit = (props: any) => (
  <Edit {...props} redirect="list">
    <SimpleForm>
      <TextInput source="id" disabled sx={user_sx} />
      <TextInput source="email" sx={user_sx} />
      <TextInput source="username" sx={user_sx} />
      <UserRoleInput />
      <TextInput source="email" sx={user_sx} />
      <TextInput source="email" sx={user_sx} />
      <NumberInput source="age" min={14} max={100} />
      <TextInput source="phone" sx={user_sx} />
      <BooleanInput
        {...props}
        source="is_active"
        defaultValue={true}
        sx={user_sx}
      />
    </SimpleForm>
  </Edit>
);

export const UserCreate = (props: any) => {
  return (
    <Create {...props} redirect="list">
      <SimpleForm mode="onBlur" reValidateMode="onBlur">
        <TextInput source="email" sx={user_sx} validate={required()} />
        <PasswordInput source="password" sx={user_sx} validate={required()} />
        <TextInput source="username" sx={user_sx} validate={required()} />
        <UserRoleInput validate={required()} />
        <NumberInput source="age" min={14} max={100} />
        <TextInput source="phone" sx={user_sx} />
      </SimpleForm>
    </Create>
  );
};
