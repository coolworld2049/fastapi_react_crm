import { useCreateSuggestionContext } from "react-admin";
import React from "react";
import { studyGroupCiphersApi } from "../providers/env";
import { Button, Dialog, DialogActions, DialogContent } from "@mui/material";
import TextField from "@mui/material/TextField";

export const StudyGroupCipherOptionCreate = () => {
  const { filter, onCancel, onCreate } = useCreateSuggestionContext();
  const [cipher, setCipher] = React.useState(filter || "");

  const handleSubmit = (event: { preventDefault: () => void }) => {
    event.preventDefault();
    const newOption = { cph: cipher };
    studyGroupCiphersApi
      .createStudyGroupCipherApiV1StudyGroupCiphersPost({ id: newOption.cph })
      .then((r) => {
        setCipher("");
        onCreate(newOption);
      })
      .catch((e) => setCipher(e));
  };

  return (
    <Dialog onClose={onCancel} open={true}>
      <form onSubmit={handleSubmit}>
        <DialogContent>
          <TextField
            label="Cipher"
            value={cipher}
            onChange={(event) => setCipher(event.target.value)}
            autoFocus
          />
        </DialogContent>
        <DialogActions>
          <Button type="submit">Save</Button>
          <Button onClick={onCancel}>Cancel</Button>
        </DialogActions>
      </form>
    </Dialog>
  );
};
