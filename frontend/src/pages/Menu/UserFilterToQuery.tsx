export const filterToQueryCompany = (searchText: any) => ({
  name: `${searchText}`,
});

export const filterToQueryStudent = (searchText: any) => ({
  email: `${searchText}`,
  role: ["student", "student_leader", "student_leader_assistant"],
});

export const filterToQueryTeacher = (searchText: any) => ({
  email: `${searchText}`,
  role: "teacher",
});

export const customOptionTextStudent = (record: { email: any; role: any }) =>
  `${record.email}, ${record.role}`;

export const customOptionTextTeacher = (record: { email: any; role: any }) =>
  `${record.email}, ${record.role}`;

export const customOptionTextCampus = (record: { id: any; address: any }) =>
  `${record.id}, ${record.address}`;

export const customOptionTextDiscipline = (record: {
  title: any;
  assessment: any;
}) => `${record.title}, ${record.assessment}`;

export const customOptionTextStudyGroupCipher = (record: { id: any }) =>
  `${record.id}`;

export const customOptionTextStudyGroup = (record: {
  study_group_cipher_id: any;
  discipline_id: any;
}) => `${record.study_group_cipher_id}`;
