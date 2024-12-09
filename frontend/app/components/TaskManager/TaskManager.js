"use client";

import React, { useState } from "react";
import { Button, Modal, TextInput } from "@mantine/core";
import { useDisclosure } from "@mantine/hooks";
import { AddCardModal } from "./AddCardModal";
import { AiOutlineDelete } from "react-icons/ai";
import { GrCheckmark } from "react-icons/gr";
import { CiEdit } from "react-icons/ci";

export const TaskManager = ({ initialCards }) => {
  const [cards, setCards] = useState(initialCards);
  const [addModalOpened, addModalHandlers] = useDisclosure(false);

  const getCards = async () => {
    const response = await fetch("api/proxy/get-tasks");
    if (response.ok) {
      const cards = await response.json();
      return cards;
    }
    return [];
  };

  const addCard = async () => {
    const cards = await getCards();
    setCards(cards);
  };

  const handleRemoveCard = async (task_id) => {
    try {
      console.log(
        `Sending DELETE request to /api/proxy/remove-task?id=${task_id}`
      );

      const response = await fetch(`/api/proxy/remove-task?id=${task_id}`, {
        method: "DELETE",
      });

      if (!response.ok) {
        throw new Error("Failed to remove task");
      } else {
        if (response.ok) {
          setCards(await getCards());
          console.log(cards);
        }
      }
    } catch (error) {
      console.error("Error submitting form:", error);
    }
  };

  return (
    <div className="">
      <AddCardModal
        addCard={addCard}
        opened={addModalOpened}
        onClose={addModalHandlers.close}
      />

      <div
        className="flex justify-around mx-[15%] sm:mx-[20%]
       md:mx-[25%] lg:mx-[30%] xl:mx-[40%] mb-4"
      >
        <Button variant="default" onClick={addModalHandlers.open}>
          Add Task
        </Button>
      </div>

      <div className="overflow-hidden grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 mx-[5%] md:mx-[10%] lg:mx-[15%] ">
        {cards.map((card) => (
          <div
            key={card.task_id}
            className={"border p-4 rounded m-2 cursor-pointer flex-1"}
          >
            <div className="w-full">
              <h3 className="font-semibold">{card.description}</h3>
              <div className="flex justify-between items-center">
                <p>Points: {card.points}</p>
                <div>
                  <Button variant="subtle" color="red" size="compact-md">
                    <AiOutlineDelete />
                  </Button>
                  <Button variant="subtle" color="black" size="compact-md">
                    <CiEdit />
                  </Button>
                  <Button variant="subtle" color="black" size="compact-md">
                    <GrCheckmark />
                  </Button>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
