"use client";

import { Modal, Textarea } from "@mantine/core";
import { useForm } from "@mantine/form";
import { TextInput, Select, NumberInput, Button, Box } from "@mantine/core";

const AddCardForm = () => {
  const form = useForm({
    initialValues: {
      description: "",
      recurring: "",
      points: 0,
    },

    validate: {
      description: (value) =>
        value.length === 0
          ? "Description is required"
          : value.length > 200
          ? "Description must be 200 characters or less"
          : null,
      recurring: (value) => (!value ? "Please select daily or weekly" : null),
      points: (value) =>
        value < 0 || value > 10 ? "Points must be between 0 and 10" : null,
    },
  });

  return (
    <Box mx="auto" maw={400}>
      <form onSubmit={form.onSubmit((values) => console.log(values))}>
        <Textarea
          label="Description"
          placeholder="Enter a description"
          autosize
          {...form.getInputProps("description")}
        />

        <Select
          label="Recurring"
          placeholder="Select an option"
          data={[
            { value: "daily", label: "Daily" },
            { value: "weekly", label: "Weekly" },
          ]}
          {...form.getInputProps("recurring")}
        />

        <NumberInput
          label="Points"
          placeholder="Enter a number"
          min={0}
          max={10}
          {...form.getInputProps("points")}
        />

        <Button type="submit" mt="sm">
          Submit
        </Button>
      </form>
    </Box>
  );
};

export const AddCardModal = ({ setCards, opened, onClose }) => {
  return (
    <>
      <Modal opened={opened} onClose={onClose} title="Add a new task">
        <AddCardForm></AddCardForm>
      </Modal>
    </>
  );
};
