import {
  createContext,
  useState,
  useCallback,
  useMemo,
  useContext,
} from "react";
import {
  TextInput,
  SimpleForm,
  useNotify,
  SaveContextProvider,
  useGetIdentity,
  usePermissions,
  useRedirect,
  Toolbar,
  SaveButton,
  NumberInput,
} from "react-admin";
import { userApi } from "../../providers/env";

const ProfileContext = createContext({
  profileVersion: 0,
  refreshProfile: () => {},
});

export const ProfileProvider = ({ children }: { children: any }) => {
  const [profileVersion, setProfileVersion] = useState(0);
  const context = useMemo(
    () => ({
      profileVersion,
      refreshProfile: () => {
        setProfileVersion((currentVersion) => currentVersion + 1);
      },
    }),
    [profileVersion]
  );

  return (
    <ProfileContext.Provider value={context}>
      {children}
    </ProfileContext.Provider>
  );
};

export const useProfile = () => useContext(ProfileContext);

const CustomToolbar = (props: any) => (
  <Toolbar {...props}>
    <SaveButton />
  </Toolbar>
);

export const ProfileEdit = ({ ...props }) => {
  const notify = useNotify();
  const { isLoading: isPermissionsLoading, permissions } = usePermissions();
  const redirect = useRedirect();
  if (!isPermissionsLoading && !permissions?.email) {
    redirect("/login/access-token");
  }
  const [saving, setSaving] = useState(false);
  const { refreshProfile, profileVersion } = useProfile();
  const { isLoading: isUserIdentityLoading, identity } = useGetIdentity();

  const handleSave = useCallback(
    (userUpdate: any) => {
      setSaving(true);
      userApi
        .updateUserApiV1UsersIdPut(userUpdate.id, userUpdate)
        .then(() => {
          setSaving(false);
          notify("Your profile has been updated", { type: "info" });
          refreshProfile();
          return redirect("/");
        })
        .catch((e) => {
          setSaving(false);
          notify(
            e.response?.data?.detail || "Unknown error, please try again later",
            { type: "error" }
          );
        });
    },
    [notify]
  );

  if (isUserIdentityLoading) {
    return null;
  }

  return (
    <SaveContextProvider
      value={{ save: handleSave, saving }}
      key={profileVersion}
    >
      <SimpleForm record={identity ? identity : {}} toolbar={<CustomToolbar />}>
        <TextInput source="email" />
        <TextInput source="username" />
        <TextInput source="role" disabled />
        <TextInput source="phone" />
        <NumberInput source="age" min={14} max={100} />
      </SimpleForm>
    </SaveContextProvider>
  );
};
