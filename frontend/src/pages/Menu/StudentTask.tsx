import {
  AutocompleteInput,
  ChipField,
  Datagrid,
  DateField,
  List,
  NumberField,
  NumberInput,
  ReferenceField,
  ReferenceInput,
  RichTextField,
  SimpleShowLayout,
  TextField,
} from "react-admin";
import { DateInput, Edit, SimpleForm, TextInput } from "react-admin";
import { RichTextInput } from "ra-input-rich-text";

const StudentTaskPanel = (props: any) => (
  <SimpleShowLayout {...props}>
    <RichTextField source="comment" />
  </SimpleShowLayout>
);

export const StudentTaskList = () => (
  <List>
    <Datagrid rowClick="edit" expand={StudentTaskPanel}>
      <ReferenceField source="id" reference="tasks" link="show">
        <TextField source="id" />
      </ReferenceField>
      <ReferenceField source="id" reference="tasks" link="show">
        <ReferenceField source="student_id" reference="users/role/students">
          <TextField source="email" />
        </ReferenceField>
      </ReferenceField>
      <ChipField source="grade" />
      <NumberField source="points" />
      <DateField source="deadline_date" showTime={true} />
      <DateField source="start_date" showTime={true} />
      <DateField source="completion_date" showTime={true} />
    </Datagrid>
  </List>
);

export const StudentTaskEdit = () => (
  <Edit>
    <SimpleForm>
      <TextInput source="id" disabled />
      <NumberInput source="points" min={0} max={25} />
      <RichTextInput source="comment" />
      <RichTextInput source="feedback" />
      <ReferenceInput source="grade" reference="classifiers/student_task_grade">
        <AutocompleteInput source="id" />
      </ReferenceInput>
      <DateInput source="deadline_date" />
      <DateInput source="start_date" />
      <DateInput source="completion_date" />
    </SimpleForm>
  </Edit>
);
