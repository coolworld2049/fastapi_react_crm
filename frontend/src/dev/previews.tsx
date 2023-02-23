import React from "react";
import { ComponentPreview, Previews } from "@react-buddy/ide-toolbox";
import { PaletteTree } from "./palette";
import App from "../App";
import { UserCreate } from "../pages/Menu/Users";

const ComponentPreviews = () => {
  return (
    <Previews palette={<PaletteTree />}>
      <ComponentPreview path="/App">
        <App />
      </ComponentPreview>
      <ComponentPreview path="/UserCreate">
        <UserCreate />
      </ComponentPreview>
    </Previews>
  );
};

export default ComponentPreviews;
