"use client";

import { Modal, Textarea } from "@mantine/core";
import { useForm } from "@mantine/form";
import { TextInput, Select, NumberInput, Button, Box } from "@mantine/core";

const AddCardForm = ({ addCard, onClose }) => {
  const form = useForm({
    initialValues: {
      description: "",
      recurrence_type: "",
      points: 1,
      task_id: 0, // placeholder
    },

    validate: {
      description: (value) =>
        value.length === 0
          ? "Description is required"
          : value.length > 200
          ? "Description must be 200 characters or less"
          : null,
      recurrence_type: (value) =>
        !value ? "Please select daily or weekly" : null,
      points: (value) =>
        value < 1 || value > 10 ? "Points must be between 1 and 10" : null,
      task_id: (_) => null,
    },
  });

  const handleSubmit = async (values) => {
    try {
      const response = await fetch("/api/proxy/add-task", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(values),
      });

      if (!response.ok) {
        throw new Error("Failed to add task");
      }

      // Update state with the new task and close modal
      addCard({ points: values.points, description: values.description });
      onClose();
    } catch (error) {
      console.error("Error submitting form:", error);
    }
  };

  return (
    <Box mx="auto" maw={400}>
      <form onSubmit={form.onSubmit(handleSubmit)}>
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
            { value: "Daily", label: "Daily" },
            { value: "Weekly", label: "Weekly" },
          ]}
          {...form.getInputProps("recurrence_type")}
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

export const AddCardModal = ({ addCard, opened, onClose }) => {
  return (
    <>
      <Modal opened={opened} onClose={onClose} title="Add a new task">
        <AddCardForm addCard={addCard} onClose={onClose} />
      </Modal>
    </>
  );
};
