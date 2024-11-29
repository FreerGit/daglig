"use client";

import React, { useState } from "react";
import { Button, Modal, TextInput } from "@mantine/core";
import { useDisclosure } from "@mantine/hooks";
import { AddCardModal } from "./AddCardModal";

import styles from "../../styles/CardManager.module.css";

export const TaskManager = ({ initialCards }) => {
  const [cards, setCards] = useState(initialCards);
  const [isRemoving, setIsRemoving] = useState(false);
  const [addModalOpened, addModalHandlers] = useDisclosure(false);

  const [hoveredCard, setHoveredCard] = useState(null);

  const toggleRemoveMode = () => {
    setIsRemoving((prev) => !prev);
  };

  const addCard = (card) => {
    setCards([...cards, card]);
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
        const response = await fetch("/api/proxy/get-tasks", {
          method: "GET",
        });

        if (response.ok) {
          setCards(await response.json());
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
        <Button variant="default" onClick={toggleRemoveMode}>
          {isRemoving ? "Cancel" : "Remove"}
        </Button>
        <Button variant="default" onClick={() => setEditModalOpen(true)}>
          Update
        </Button>
        <Button variant="default" onClick={addModalHandlers.open}>
          Add
        </Button>
      </div>

      <div className="overflow-hidden grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 mx-[5%] md:mx-[10%] lg:mx-[15%] ">
        {cards.map((card) => (
          <div
            key={card.task_id}
            className={`border p-4 rounded m-2 cursor-pointer flex-1 ${
              hoveredCard === card.task_id ? "bg-red-200" : ""
            } ${isRemoving ? `${styles.card}` : ""}`}
            style={{
              animationDelay: `${-0.1 + card.task_id * -0.05}s`, // Adjust delay based on index
              animationDuration: "0.3s", // Fixed duration
            }}
            onMouseEnter={() => isRemoving && setHoveredCard(card.task_id)}
            onMouseLeave={() => isRemoving && setHoveredCard(null)}
            onClick={() => handleRemoveCard(card.task_id)}
          >
            <div className="w-full">
              <h3 className="font-semibold">{card.description}</h3>
              <div className="flex justify-between items-center">
                <p>Points: {card.points}</p>
                {isRemoving ? (
                  <></>
                ) : (
                  <Button variant="subtle" color="green">
                    ✔
                  </Button>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
