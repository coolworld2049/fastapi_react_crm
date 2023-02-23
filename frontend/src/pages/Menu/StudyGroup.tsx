import {
  AutocompleteInput,
  ChipField,
  Create,
  Datagrid,
  DateField,
  List,
  ReferenceArrayInput,
  ReferenceField,
  ReferenceInput,
  ReferenceManyField,
  SelectArrayInput,
  SimpleShowLayout,
  SingleFieldList,
  TextField,
  useRedirect,
  useRefresh,
} from "react-admin";
import { Edit, SimpleForm, TextInput } from "react-admin";
import { ListItem } from "@material-ui/core";
import { StudyGroupCipherOptionCreate } from "../../components/StudyGroupCipherOptionCreate";
import React from "react";

export const PanelStudyGroupTaskTeacher = (props: any) => (
  <ReferenceField source="id" reference="tasks" link={false}>
    <SimpleShowLayout>
      <TextField source="description" />
      <DateField source="create_date" showTime={true} />
    </SimpleShowLayout>
  </ReferenceField>
);

export const PanelStudyGroupTask = (props: any) => (
  <ReferenceManyField
    source="id"
    reference="study_group_tasks"
    target="study_group_cipher_id"
  >
    <Datagrid
      bulkActionButtons={false}
      expand={PanelStudyGroupTaskTeacher}
      expandSingle
    >
      <TextField source="title"></TextField>
      <ChipField source="priority" />
      <DateField source="deadline_date" showTime={true} />
    </Datagrid>
  </ReferenceManyField>
);

export const PanelStudyGroupDisciplines = (props: any) => (
  <ListItem>
    <ReferenceManyField source="id" reference="study_groups" target="id">
      <SingleFieldList sx={{ mr: 200 }}>
        <ReferenceField
          reference={"disciplines"}
          source={"discipline_id"}
          link="show"
          label={"Discipline"}
        >
          <ChipField source={"title"} />
        </ReferenceField>
      </SingleFieldList>
    </ReferenceManyField>
  </ListItem>
);

export const StudyGroupList = () => (
  <List>
    <Datagrid
      rowClick="edit"
      bulkActionButtons={false}
      expand={PanelStudyGroupDisciplines}
    >
      <ReferenceField source="id" reference="study_group_ciphers">
        <TextField source="id" />
      </ReferenceField>
    </Datagrid>
  </List>
);

export const StudyGroupEdit = () => (
  <Edit>
    <SimpleForm>
      <TextInput source="id" />
    </SimpleForm>
  </Edit>
);

export const StudyGroupCreate = () => {
  const refresh = useRefresh();
  const redirect = useRedirect();
  return (
    <Create resource="study_groups">
      <SimpleForm onSubmit={() => redirect("/study_group_ciphers")}>
        <ReferenceInput source="id" reference="study_group_ciphers">
          <AutocompleteInput
            source="id"
            optionValue="id"
            optionText={(record: { id: any }) => `${record.id}`}
            filterToQuery={(searchText: any) => ({ id: `${searchText}` })}
            onOpen={() => refresh()}
            create={<StudyGroupCipherOptionCreate />}
          />
        </ReferenceInput>
        <ReferenceArrayInput source="discipline_id" reference="disciplines">
          <SelectArrayInput
            source="discipline_id"
            optionText="title"
            optionValue="id"
          />
        </ReferenceArrayInput>
      </SimpleForm>
    </Create>
  );
};
