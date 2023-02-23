import {
  AutocompleteInput,
  Datagrid,
  List,
  ReferenceField,
  TextField,
  UrlField,
  WithRecord,
} from "react-admin";
import { Edit, ReferenceInput, SimpleForm, TextInput } from "react-admin";

function formatBytes(a: number, b = 2) {
  if (!+a) return "0 Bytes";
  const c = 0 > b ? 0 : b,
    d = Math.floor(Math.log(a) / Math.log(1024));
  return `${parseFloat((a / Math.pow(1024, d)).toFixed(c))} ${
    ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"][d]
  }`;
}

export const StudentTaskStoreList = () => {
  return (
    <List>
      <Datagrid rowClick="edit">
        <ReferenceField source="task_id" reference="tasks" link="show">
          <TextField source="title" />
          <TextField source="study_group_cipher_id" />
          <TextField source="student_id" />
        </ReferenceField>
        <UrlField source="url" />
        <TextField source="filename" emptyText={"not set"} />
        <WithRecord
          label="Size"
          render={(record) => <span>{formatBytes(record.size / 8)}</span>}
        />
      </Datagrid>
    </List>
  );
};

export const StudentTaskStoreEdit = () => (
  <Edit>
    <SimpleForm>
      <ReferenceInput source="task_id" reference="tasks">
        <AutocompleteInput optionText="id" optionValue="id" disabled />
      </ReferenceInput>
      <TextInput source="url" />
      <TextInput source="filename" />
    </SimpleForm>
  </Edit>
);
