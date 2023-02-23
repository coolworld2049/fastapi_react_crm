import moment from "moment-timezone";
import { readTimeZone } from "../providers/env";

export const dateParser = (value: any) => {
  return moment.tz(value, readTimeZone()).format();
};
