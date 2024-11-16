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

  const [selectedCards, setSelectedCards] = useState(new Set());

  const toggleRemoveMode = () => {
    setIsRemoving((prev) => !prev);
  };

  const addCard = (card) => {
    setCards([...cards, card]);
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
        {cards.map((card, index) => (
          <div
            key={card.id}
            className={`border p-4 rounded m-2 cursor-pointer flex-1 ${
              isRemoving ? (selectedCards.has(card.id) ? "bg-red-200" : "") : ""
            } ${isRemoving ? `${styles.card}` : ""}`}
            style={{
              animationDelay: `${-0.1 + index * -0.05}s`, // Adjust delay based on index
              animationDuration: "0.3s", // Fixed duration
            }}
            onClick={() => isRemoving && toggleCardSelectionkat(card.id)}
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
