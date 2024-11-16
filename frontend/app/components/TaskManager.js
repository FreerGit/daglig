"use client";

import React, { useState } from "react";
import { Button, Modal, TextInput } from "@mantine/core";
import styles from "../styles/CardManager.module.css";

export const TaskManager = ({ initialCards }) => {
  const [cards, setCards] = useState(initialCards);
  const [isRemoving, setIsRemoving] = useState(false);
  const [selectedCards, setSelectedCards] = useState(new Set());
  const [editCard, setEditCard] = useState(null);
  const [isEditModalOpen, setEditModalOpen] = useState(false);
  const [newCardDescription, setNewCardDescription] = useState("");

  const toggleRemoveMode = () => {
    setIsRemoving((prev) => !prev);
  };

  const toggleCardSelection = (id) => {
    setSelectedCards((prev) => {
      const updatedSelection = new Set(prev);
      if (updatedSelection.has(id)) {
        updatedSelection.delete(id);
      } else {
        updatedSelection.add(id);
      }
      return updatedSelection;
    });
  };

  const removeSelectedCards = () => {
    // Logic to remove cards from the database
    const updatedCards = cards.filter((card) => !selectedCards.has(card.id));
    setCards(updatedCards);
    setSelectedCards(new Set()); // Clear selections
    setIsRemoving(false); // Exit remove mode
  };

  const openEditModal = (card) => {
    setEditCard(card);
    setNewCardDescription(card.description);
    setEditModalOpen(true);
  };

  const handleUpdateCard = async () => {
    // Logic to update the card in the database

    // Update local state
    setCards((prevCards) =>
      prevCards.map((card) =>
        card.id === editCard.id
          ? { ...card, description: newCardDescription }
          : card
      )
    );

    setEditModalOpen(false);
    setEditCard(null);
    setNewCardDescription("");
  };

  const handleAddCard = async () => {
    // Logic to add a new card to the database

    // Update local state
    const newCard = {
      id: Date.now(), // Replace with actual ID from DB
      description: newCardDescription,
      points: 0, // Set default points or any logic you have
    };
    setCards((prevCards) => [...prevCards, newCard]);

    setNewCardDescription("");
  };

  return (
    <div className="">
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
        <Button variant="default" onClick={() => handleAddCard()}>
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

{
  /* {isRemoving && selectedCards.size > 0 && (
        <Button onClick={removeSelectedCards} className="mt-4">
          Confirm Removal
        </Button>
      )}


      <Modal
        opened={isEditModalOpen}
        onClose={() => setEditModalOpen(false)}
        title="Edit Card"
      >
        <TextInput
          label="Description"
          value={newCardDescription}
          onChange={(e) => setNewCardDescription(e.target.value)}
        />
        <Button onClick={handleUpdateCard}>Update Card</Button>
      </Modal>

      <Modal
        opened={newCardDescription !== ""} // This is a temporary approach; use a better state for modal control
        onClose={() => setNewCardDescription("")}
        title="Add New Card"
      >
        <TextInput
          label="Description"
          value={newCardDescription}
          onChange={(e) => setNewCardDescription(e.target.value)}
        />
        <Button onClick={handleAddCard}>Add Card</Button>
      </Modal> */
}
