import {
  ArrayInput,
  AutocompleteInput,
  ChipField,
  Create,
  Datagrid,
  DateField,
  List,
  NumberInput,
  PasswordInput,
  ReferenceArrayInput,
  ReferenceField,
  ReferenceManyField,
  required,
  RichTextField,
  SelectArrayInput,
  SimpleFormIterator,
  SimpleShowLayout,
  SingleFieldList,
  TextField,
  TextInput,
} from "react-admin";
import { Edit, ReferenceInput, SimpleForm } from "react-admin";
import { Chip, ListItem } from "@material-ui/core";
import FaceIcon from "@mui/icons-material/Face";
import GroupIcon from "@mui/icons-material/Group";
import React from "react";
import { task_sx, user_sx } from "../../components/commonStyles";
import { CampusOptionCreate } from "../../components/CampusOptionCreate";
import { RichTextInput } from "ra-input-rich-text";
import { TaskPriorityInput } from "./Task";

export const PanelTask = () => {
  return (
    <ReferenceField source="id" reference="tasks" link={false}>
      <SimpleShowLayout>
        <TextField source="id" />
        <RichTextField source="description" emptyText={"not set"} />
        <DateField source="create_date" showTime={true} />
      </SimpleShowLayout>

      <SimpleShowLayout>
        <ReferenceManyField
          source="id"
          reference="study_group_tasks"
          target="id"
          label="Assigned to Study Group(s)"
        >
          <SingleFieldList>
            <ChipField
              source="study_group_cipher_id"
              style={{ background: "#8758FF" }}
              icon={<GroupIcon />}
            />
          </SingleFieldList>
        </ReferenceManyField>
      </SimpleShowLayout>

      <SimpleShowLayout>
        <ReferenceManyField
          source="id"
          reference="student_tasks"
          target="id"
          label="Assigned to Student(s)"
        >
          <SingleFieldList>
            <ReferenceField
              source="student_id"
              reference="users/role/student"
              emptyText="not set"
            >
              <ChipField
                source={"full_name"}
                style={{ background: "#8758FF" }}
                icon={<FaceIcon />}
              />
            </ReferenceField>
          </SingleFieldList>
        </ReferenceManyField>
      </SimpleShowLayout>
    </ReferenceField>
  );
};

export const PanelTeacherTask = (props: any) => {
  return (
    <ListItem>
      <ReferenceManyField
        source="user_id"
        reference="tasks"
        target="teacher_user_id"
      >
        <Datagrid bulkActionButtons={false} expand={<PanelTask />}>
          <TextField source="title" />
        </Datagrid>
      </ReferenceManyField>
      <SimpleShowLayout>
        <ReferenceField source="discipline_id" reference="disciplines">
          <TextField source="title" />
        </ReferenceField>
      </SimpleShowLayout>
      <SimpleShowLayout>
        <TextField source="campus_id" />
      </SimpleShowLayout>
      <SimpleShowLayout>
        <TextField source="room_number" label={"room"} emptyText={"not set"} />
      </SimpleShowLayout>
    </ListItem>
  );
};

export const TeacherList = () => (
  <List>
    <Datagrid
      rowClick="show"
      bulkActionButtons={false}
      expand={<PanelTeacherTask />}
      expandSingle
    >
      <ReferenceField
        source="user_id"
        reference="users/role/teacher"
        link={(record, reference) => `/users/${record.user_id}/show`}
      >
        <TextField source="email" />
      </ReferenceField>
      <ChipField source="role" label={"Teacher Role"} />
    </Datagrid>
  </List>
);

export const TeacherEdit = () => (
  <Edit>
    <SimpleShowLayout>
      <TextField source="id" label={"Teacher"} />
    </SimpleShowLayout>
    <SimpleForm>
      <ReferenceInput source="user_id" reference="users/role/teachers">
        <TextField source="email" />
      </ReferenceInput>
      <ReferenceInput source="discipline_id" reference="disciplines">
        <AutocompleteInput source="title" optionText="title" optionValue="id" />
      </ReferenceInput>
    </SimpleForm>
  </Edit>
);

export const TeacherCreate = () => (
  <Create>
    <SimpleForm>
      <TextInput source="email" sx={user_sx} validate={required()} />
      <PasswordInput source="password" sx={user_sx} validate={required()} />
      <TextInput source="username" sx={user_sx} validate={required()} />
      <TextInput
        source="role"
        defaultValue={"teacher"}
        label={"User Role"}
        disabled
      />
      <TextInput source="email" sx={user_sx} />
      <NumberInput source="age" min={14} max={100} />
      <TextInput source="phone" sx={user_sx} />

      <ArrayInput source="discipline_id" validate={required()}>
        <SimpleFormIterator inline>
          <ReferenceInput source="discipline_id" reference="disciplines">
            <AutocompleteInput
              source="title"
              optionText="title"
              optionValue="id"
              label="Disciplines"
            />
          </ReferenceInput>
          <ReferenceInput source="role" reference="classifiers/teacher_role">
            <AutocompleteInput
              source="id"
              optionText="id"
              label={"Teacher Role"}
            />
          </ReferenceInput>
          <ReferenceInput source="campus_id" reference="campuses">
            <AutocompleteInput
              source="id"
              optionValue="id"
              optionText={(record: { id: any }) => `${record.id}`}
              filterToQuery={(searchText: any) => ({ id: `${searchText}` })}
              create={<CampusOptionCreate />}
            />
          </ReferenceInput>
          <TextInput source="classroom_number" />
        </SimpleFormIterator>
      </ArrayInput>
    </SimpleForm>
  </Create>
);

export const TeacherTaskCreate = (props: any) => {
  return (
    <Create redirect="list">
      <SimpleForm>
        <ReferenceInput source="teacher_user_id" reference="users/me">
          <TextInput source="id" disabled />
        </ReferenceInput>
        <ReferenceInput source="teacher_role" reference="teachers/me">
          <AutocompleteInput
            optionText="role"
            optionValue="role"
            sx={task_sx}
            label={"Teacher Role"}
          />
        </ReferenceInput>
        <ReferenceInput source="teacher_discipline_id" reference="teachers/me">
          <AutocompleteInput
            optionText="discipline_id"
            optionValue="discipline_id"
            filterToQuery={(searchText: any) => ({ email: `${searchText}` })}
            sx={task_sx}
            label={"Teacher Discipline"}
          />
        </ReferenceInput>
        <TextInput source="title" sx={task_sx} />
        <RichTextInput source="description" sx={task_sx} />
        <TaskPriorityInput {...props} sx={task_sx} />
        <ReferenceArrayInput
          source="study_group_cipher_id"
          reference="study_group_ciphers"
        >
          <SelectArrayInput
            source="id"
            optionValue="id"
            label={"Assign to Study Groups"}
            optionText={(record: { id: any }) => `${record.id}`}
          />
        </ReferenceArrayInput>
        <ReferenceArrayInput source="student_id" reference="students">
          <SelectArrayInput
            source="id"
            optionValue="id"
            label={"Assign to Students"}
            optionText={(record: { id: any }) => `${record.id}`}
          />
        </ReferenceArrayInput>
      </SimpleForm>
    </Create>
  );
};
