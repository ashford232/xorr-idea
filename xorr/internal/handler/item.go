package handler

import (
	"encoding/json"
	"log"
	"net/http"
	"time"
	"xorr/internal/database"
	"xorr/internal/middleware"

	"github.com/go-chi/chi/v5"
)

type Note struct {
	ID        int       `json:"id"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	UserId    int       `josn:"user_id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func CreateNote(w http.ResponseWriter, r *http.Request) {
	userId := r.Context().Value(middleware.UserIdKey).(int)
	var note Note
	json.NewDecoder(r.Body).Decode(&note)

	err := database.DB.QueryRow(
		"INSERT INTO notes (title, content, user_id, created_at, updated_at) VALUES($1,$2,$3,$4,$5) RETURNING id",
		note.Title, note.Content, note.UserId, note.CreatedAt, note.UpdatedAt,
	).Scan(&note.ID)
	if err != nil {
		http.Error(w, "Errro saving item", http.StatusInternalServerError)
		return
	}
	note.UserId = userId
	w.WriteHeader(http.StatusCreated)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(note)
}

func GetNotes(w http.ResponseWriter, r *http.Request) {
	userId := r.Context().Value(middleware.UserIdKey).(int)

	rows, err := database.DB.Query("SELECT id, title, content, user_id, created_at, updated_at FROM notes WHERE user_id=$1", userId)
	if err != nil {
		log.Printf("Query error: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var notes []Note

	for rows.Next() {
		var n Note
		if err := rows.Scan(&n.ID, &n.Title, &n.Content, &n.UserId, &n.CreatedAt, &n.UpdatedAt); err != nil {
			log.Printf("Row scan error: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}
		notes = append(notes, n)
	}
	if err := rows.Err(); err != nil {
		log.Printf("Rows iteration error %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	json.NewEncoder(w).Encode(notes)
}

func UpdateNote(w http.ResponseWriter, r *http.Request) {
	userId := r.Context().Value(middleware.UserIdKey).(int)
	id := chi.URLParam(r, "id")
	var note Note
	json.NewDecoder(r.Body).Decode(&note)
	result, err := database.DB.Exec("UPDATE notes SET title=$1, content=$2, updated_at=$3 WHERE id=$4 AND user_id=$5", note.Title, note.Content, note.UpdatedAt, id, userId)

	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	if rowsAffected == 0 {
		http.Error(w, "Note with the given ID not found", http.StatusBadRequest)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Note updated"})
}

func DeleteNote(w http.ResponseWriter, r *http.Request) {
	userId := r.Context().Value(middleware.UserIdKey).(int)
	id := chi.URLParam(r, "id")
	result, err := database.DB.Exec("DELETE FROM notes WHERE id=$1 AND user_id=$2", id, userId)
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
		http.Error(w, "Note with the given ID not found", http.StatusBadRequest)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
