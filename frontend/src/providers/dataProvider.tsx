import simpleRestProvider from "ra-data-simple-rest";
import { basePath } from "./env";
import { fetchUtils } from "react-admin";

const httpClient = (url: string, options: any = {}) => {
  options.user = {
    authenticated: true,
    token: `Bearer ${localStorage.getItem("token")}`,
  };
  return fetchUtils.fetchJson(url, options);
};
export const dataProvider = simpleRestProvider(
  `${basePath}/api/v1`,
  httpClient
);
