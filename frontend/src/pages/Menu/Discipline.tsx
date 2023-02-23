import {
  ChipField,
  Create,
  Datagrid,
  List,
  ReferenceField,
  ReferenceManyField,
  TextField,
} from "react-admin";
import { Edit, SimpleForm, TextInput } from "react-admin";
import { ListItem } from "@material-ui/core";

export const PanelTeacherDiscipline = (props: any) => (
  <ListItem>
    <ReferenceManyField source="id" reference="teachers" target="discipline_id">
      <Datagrid bulkActionButtons={false}>
        <ReferenceField
          source="user_id"
          reference="users/role/teacher"
          label={"Teacher"}
          link={(record) => `/teachers/${record.user_id}/show`}
        >
          <TextField source="email" />
          <ChipField source="role" />
        </ReferenceField>
        <ChipField source="role" />
      </Datagrid>
    </ReferenceManyField>
  </ListItem>
);

export const DisciplineList = () => (
  <List>
    <Datagrid
      rowClick="edit"
      bulkActionButtons={false}
      expand={PanelTeacherDiscipline}
    >
      <TextField source="title" />
    </Datagrid>
  </List>
);

export const DisciplineEdit = () => (
  <Edit>
    <SimpleForm>
      <TextInput source="title" />
    </SimpleForm>
  </Edit>
);

export const DisciplineCreate = () => (
  <Create resource="study_groups">
    <SimpleForm>
      <TextInput source="title" />
    </SimpleForm>
  </Create>
);
