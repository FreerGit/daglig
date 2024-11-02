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
    <div>
      <div className="flex justify-around mb-4">
        <Button onClick={toggleRemoveMode}>
          {isRemoving ? "Cancel" : "Remove"}
        </Button>
        <Button onClick={() => setEditModalOpen(true)}>Update</Button>
        <Button onClick={() => handleAddCard()}>Add</Button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4 w-full max-w-3xl">
        {cards.map((card, index) => (
          <div
            key={card.id}
            className={`border p-4 rounded m-2 cursor-pointer ${
              isRemoving ? (selectedCards.has(card.id) ? "bg-red-200" : "") : ""
            } ${isRemoving ? `${styles.card}` : ""} `}
            style={{
              animationDelay: `${-0.1 + index * -0.05}s`, // Adjust delay based on index
              animationDuration: "0.3s", // Fixed duration
            }}
            onClick={() => isRemoving && toggleCardSelection(card.id)}
          >
            <h3 className="font-semibold">{card.description}</h3>
            <div className="flex">
              <p>Points: {card.points}</p>
              {isRemoving ? <></> : <Button>fdsa</Button>}
            </div>
          </div>
        ))}
      </div>

      {isRemoving && selectedCards.size > 0 && (
        <Button onClick={removeSelectedCards} className="mt-4">
          Confirm Removal
        </Button>
      )}

      {/* Modals */}
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

      {/* Add Modal */}
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
      </Modal>
    </div>
  );
};
