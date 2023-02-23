import { UserIdentity } from "react-admin";
import { authApi, userApi } from "./env";

type loginFormType = {
  email: string;
  password: string;
};

const authProvider = {
  login: async ({ email, password }: loginFormType) => {
    const formData = { username: email, password };
    const resp = await authApi.loginAccessTokenApiV1LoginAccessTokenPost(
      formData.username,
      formData.password
    );
    localStorage.setItem("token", <string>resp.data.access_token);
    return Promise.resolve();
  },
  logout: () => {
    localStorage.removeItem("token");
    return Promise.resolve();
  },
  checkError: (error: { status: number }) => {
    const status = error.status;
    if (status === 401 || status === 403) {
      localStorage.removeItem("token");
      return Promise.reject();
    }
    return Promise.resolve();
  },
  checkAuth: (a: any) => {
    return localStorage.getItem("token") ? Promise.resolve() : Promise.reject();
  },
  getPermissions: () => {
    const permissions = JSON.parse(localStorage.getItem("permissions") || "{}");
    return permissions ? Promise.resolve(permissions) : Promise.reject();
  },
  getIdentity: async (): Promise<UserIdentity> => {
    const resp = await userApi.readUserMeApiV1UsersMeGet();
    localStorage.setItem("permissions", JSON.stringify(resp.data));
    return resp.data as unknown as UserIdentity;
  },
};

export default authProvider;
