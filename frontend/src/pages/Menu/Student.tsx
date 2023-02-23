import {
  AutocompleteInput,
  ChipField,
  Create,
  Datagrid,
  DateField,
  Edit,
  List,
  NumberInput,
  PasswordInput,
  ReferenceField,
  ReferenceInput,
  ReferenceManyField,
  required,
  RichTextField,
  SimpleForm,
  SimpleShowLayout,
  TextField,
  TextInput,
} from "react-admin";
import { ListItem } from "@material-ui/core";
import { user_sx } from "../../components/commonStyles";

export const PanelTask = () => (
  <ReferenceField source="id" reference="tasks" link={false}>
    <SimpleShowLayout>
      <RichTextField source="description" emptyText={"not set"} />
      <RichTextField source="comment" emptyText={"not set"} />
      <TextField source="points" emptyText={"not set"} />
      <ChipField source="grade" emptyText={"not set"} />
      <DateField source="create_date" showTime={true} emptyText={"not set"} />
      <DateField
        source="completion_date"
        showTime={true}
        emptyText={"not set"}
      />
    </SimpleShowLayout>
  </ReferenceField>
);

export const PanelStudentTask = () => {
  return (
    <ReferenceManyField
      source="id"
      reference="student_tasks"
      target="student_id"
    >
      <ListItem>
        <Datagrid bulkActionButtons={false} expand={<PanelTask />} expandSingle>
          <ReferenceField
            source="id"
            reference="tasks"
            label={"Task Title | Teacher | Role"}
            link={"show"}
          >
            <TextField source="title" />
            <ReferenceField
              source="teacher_user_id"
              reference="users/role/teacher"
            >
              <ChipField source="email" style={{ background: "#6358ff" }} />
            </ReferenceField>
            <ChipField
              source="teacher_role"
              style={{ background: "#9b58ff" }}
            />
          </ReferenceField>
          <ChipField source="status" />
          <DateField
            source="deadline_date"
            showTime={true}
            emptyText={"not set"}
          />
        </Datagrid>
      </ListItem>
    </ReferenceManyField>
  );
};

export const StudentList = () => {
  return (
    <List>
      <Datagrid
        rowClick="edit"
        bulkActionButtons={false}
        expand={PanelStudentTask}
        expandSingle
      >
        <ReferenceField
          source="id"
          reference="users/role/student"
          link={(record) => `/students/${record.id}/show`}
          label={"User"}
        >
          <TextField source="email" />
        </ReferenceField>
        <ChipField source="role" label={"Role"} />
        <ReferenceField
          source="study_group_cipher_id"
          reference="study_group_ciphers"
          label={"Study Group"}
        >
          <ChipField source="id" />
        </ReferenceField>
      </Datagrid>
    </List>
  );
};

export const StudentEdit = () => (
  <Edit>
    <SimpleShowLayout>
      <ReferenceField
        source="id"
        reference="users/role/student"
        link={(record) => `/students/${record.id}/show`}
      >
        <TextField source="email" />
      </ReferenceField>
    </SimpleShowLayout>
    <SimpleForm>
      <ReferenceInput
        source="role"
        reference="classifiers/student_role"
        label={"Student Role"}
      >
        <AutocompleteInput source="id" optionText="id" />
      </ReferenceInput>
      <ReferenceInput
        source="study_group_cipher_id"
        reference="study_group_ciphers"
      >
        <AutocompleteInput source="id" optionText="id" />
      </ReferenceInput>
    </SimpleForm>
  </Edit>
);

export const StudentCreate = () => (
  <Create>
    <SimpleForm>
      <TextInput
        source="email"
        sx={user_sx}
        validate={required()}
        defaultValue={null}
      />
      <PasswordInput source="password" sx={user_sx} validate={required()} />
      <TextInput source="username" sx={user_sx} validate={required()} />
      <TextInput
        source="user_role"
        defaultValue={"student"}
        label={"User Role"}
        disabled
      />
      <TextInput source="email" sx={user_sx} defaultValue={null} />
      <NumberInput source="age" min={14} max={100} />
      <TextInput source="phone" sx={user_sx} />
      <ReferenceInput source="role" reference="classifiers/student_role">
        <AutocompleteInput
          source="role"
          optionText="id"
          optionValue="id"
          label={"Student Role"}
        />
      </ReferenceInput>
      <ReferenceInput
        source="study_group_cipher_id"
        reference="study_group_ciphers"
      >
        <AutocompleteInput source="id" optionText="id" optionValue="id" />
      </ReferenceInput>
    </SimpleForm>
  </Create>
);
