package handler

import (
	"encoding/json"
	"log"
	"net/http"
	"xorr/internal/database"
	"xorr/internal/middleware"

	"github.com/go-chi/chi/v5"
)

type Item struct {
	ID          int    `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	UserID      int    `json:"user_id"`
}

func CreateItem(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(middleware.UserIdKey).(int)
	if !ok {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var item Item
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		http.Error(w, "Invalid item", http.StatusBadRequest)
		return
	}

	err := database.DB.QueryRow(
		"INSERT INTO items (title, description, user_id) VALUES($1,$2,$3) RETURNING id",
		item.Title, item.Description, userID,
	).Scan(&item.ID)
	if err != nil {
		http.Error(w, "Error saving item", http.StatusInternalServerError)
		return
	}
	item.UserID = userID
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(item)
}

func GetItems(w http.ResponseWriter, r *http.Request) {
	userId := r.Context().Value(middleware.UserIdKey).(int)

	rows, err := database.DB.Query("SELECT id, title, description, user_id FROM items WHERE user_id=$1 ORDER BY id DESC", userId)
	if err != nil {
		log.Printf("Query error: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var items []Item

	for rows.Next() {
		var item Item
		if err := rows.Scan(&item.ID, &item.Title, &item.Description, &item.UserID); err != nil {
			log.Printf("Row scan error: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		log.Printf("Rows iteration error %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(items)
}

func UpdateItem(w http.ResponseWriter, r *http.Request) {
	userId := r.Context().Value(middleware.UserIdKey).(int)
	id := chi.URLParam(r, "id")
	var item Item
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		http.Error(w, "Invalid item", http.StatusBadRequest)
		return
	}
	result, err := database.DB.Exec("UPDATE items SET title=$1, description=$2 WHERE id=$3 AND user_id=$4", item.Title, item.Description, id, userId)

	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	if rowsAffected == 0 {
		http.Error(w, "Item with the given ID not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"message": "Item updated"})
}

func DeleteItem(w http.ResponseWriter, r *http.Request) {
	userId := r.Context().Value(middleware.UserIdKey).(int)
	id := chi.URLParam(r, "id")
	result, err := database.DB.Exec("DELETE FROM items WHERE id=$1 AND user_id=$2", id, userId)
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	if rowsAffected == 0 {
		http.Error(w, "Item with the given ID not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
