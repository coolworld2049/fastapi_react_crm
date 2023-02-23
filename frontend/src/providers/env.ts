import {
  LoginApi,
  Configuration,
  UsersApi,
  CampusesApi,
  StudyGroupCiphersApi,
} from "../generated";


const readApiBaseFromEnv = (): string => {
  return `http://${process.env.REACT_APP_DOMAIN}:${process.env.REACT_APP_PORT}`;
};

export const readTimeZone = () => {
  return process.env.TZ as string;
};

const readAccessToken = async (): Promise<string> => {
  return localStorage.getItem("token") || "";
};

export const basePath: string = readApiBaseFromEnv();

const apiConfig: Configuration = new Configuration({
  basePath,
  accessToken: readAccessToken,
});

export const authApi: LoginApi = new LoginApi(apiConfig);
export const userApi: UsersApi = new UsersApi(apiConfig);

export const campusesApi: CampusesApi = new CampusesApi(apiConfig);

export const studyGroupCiphersApi: StudyGroupCiphersApi =
  new StudyGroupCiphersApi(apiConfig);
