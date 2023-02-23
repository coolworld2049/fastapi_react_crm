import {
  UserMenu,
  MenuItemLink,
  AppBar,
  Layout,
  Logout,
  defaultTheme,
  ToggleThemeButton,
  usePermissions,
} from "react-admin";
import { ProfileProvider } from "../pages/Profile/ProfileEdit";
import SettingsIcon from "@mui/icons-material/Settings";
import { ReactQueryDevtools } from "react-query/devtools";
import { createTheme, Box, Typography } from "@mui/material";

const MyUserMenu = (props: any) => {
  // Forcing MenuItemLink to any because of some weird type mismatch, not sure what's going on
  const ItemLink = MenuItemLink as any;
  const { isLoading, permissions } = usePermissions();
  return (
    <UserMenu {...props}>
      <ItemLink
        to="/my-profile"
        primaryText="My Profile"
        leftIcon={<SettingsIcon />}
      />
      <Logout key="logout" />
    </UserMenu>
  );
};

const darkTheme = createTheme({
  palette: {
    mode: "dark",
  },
  typography: {
    // Use the system font instead of the default Roboto font.
    fontFamily: [
      "-apple-system",
      "BlinkMacSystemFont",
      '"Segoe UI"',
      "Arial",
      "sans-serif",
    ].join(","),
  },
});

const MyAppBar = (props: any) => (
  <AppBar {...props} userMenu={<MyUserMenu />}>
    <Box flex="1">
      <Typography variant="h6" id="react-admin-title"></Typography>
    </Box>
    <ToggleThemeButton lightTheme={defaultTheme} darkTheme={darkTheme} />
  </AppBar>
);

//<ReactQueryDevtools initialIsOpen={false} />
const MyLayout = (props: any) => (
  <ProfileProvider>
    <Layout {...props} appBar={MyAppBar} />
    <ReactQueryDevtools initialIsOpen={false} />
  </ProfileProvider>
);

export default MyLayout;
