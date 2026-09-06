package handler

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"xorr/internal/auth"
	"xorr/internal/database"
	"xorr/internal/middleware"
	"xorr/internal/storage"

	"golang.org/x/crypto/bcrypt"
)

type User struct {
	ID       int     `json:"id"`
	Username *string `json:"username"`
	PhotoUrl *string `json:"photo_url"`
	Email    string  `json:"email"`
	Password string  `json:"password"`
}
type Handler struct {
	R2 *storage.R2
}

var R2Storage *storage.R2

func Signup(w http.ResponseWriter, r *http.Request) {
	var input User

	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		JSONError(w, "Invalid input", http.StatusBadRequest)
		return
	}

	if input.Email == "" || input.Password == "" {
		JSONError(w, "All fields are required", http.StatusBadRequest)
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword(
		[]byte(input.Password),
		bcrypt.DefaultCost,
	)
	if err != nil {
		JSONError(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	var user User

	err = database.DB.QueryRow(
		`INSERT INTO users (
        email,
        password,
        username
    )
    VALUES ($1, $2, $3)
    RETURNING id, email, username`,
		input.Email,
		string(hashedPassword),
		nil,
	).Scan(
		&user.ID,
		&user.Email,
		&user.Username,
	)
	if err != nil {
		if strings.Contains(err.Error(), "duplicate key") ||
			strings.Contains(err.Error(), "23505") {
			JSONError(w, "Email already registered", http.StatusBadRequest)
			return
		}

		log.Printf("Database failure: %v", err)
		JSONError(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	token, err := auth.GenerateToken(user.ID)
	if err != nil {
		log.Println(err)
		JSONError(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)

	json.NewEncoder(w).Encode(map[string]interface{}{
		"message": "User registered successfully",
		"user":    user,
		"token":   token,
	})
}
func Login(w http.ResponseWriter, r *http.Request) {

	var input User

	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		JSONError(w, "Invalid input", http.StatusBadRequest)
		return
	}

	if input.Email == "" || input.Password == "" {
		JSONError(w, "All fields are required", http.StatusBadRequest)
		return
	}

	var hashedPassword string

	err := database.DB.QueryRow("SELECT id, password, username FROM users WHERE email=$1", input.Email).Scan(&input.ID, &hashedPassword, &input.Username)

	if err != nil || bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(input.Password)) != nil {
		JSONError(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	token, err := auth.GenerateToken(input.ID)
	if err != nil {
		log.Println(err)
		JSONError(w, "Internal server error", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{"message": input.Email + " logged in", "token": token, "user": input})

}
func Me(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(middleware.UserIdKey).(int)
	if !ok {
		JSONError(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var user User

	err := database.DB.QueryRow(
		"SELECT id, email, username, photo_url FROM users WHERE id=$1",
		userID,
	).Scan(
		&user.ID,
		&user.Email,
		&user.Username,
		&user.PhotoUrl,
	)

	if err != nil {
		JSONError(w, "User not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"user": user,
	})
}
func GetProfileURL(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(middleware.UserIdKey).(int)
	if !ok {
		JSONError(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	key := fmt.Sprintf("users/%d/profile.jpg", userID)

	uploadURL, err := R2Storage.CreateUploadURL(
		r.Context(),
		key,
		"image/jpeg",
	)
	publicURL := fmt.Sprintf(
		"https://pub-909d52a39d614dfeb146c185d99e1a54.r2.dev/%s",
		key,
	)
	if err != nil {
		log.Println(err)
		JSONError(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	json.NewEncoder(w).Encode(map[string]string{
		"uploadUrl": uploadURL,
		"publicUrl": publicURL,
		"key":       key,
	})
}

func UpdateUser(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(middleware.UserIdKey).(int)
	if !ok {
		JSONError(w, "Unauthorized", http.StatusUnauthorized)
		return
	}
	var user User
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		JSONError(w, err.Error(), http.StatusBadRequest)
		return
	}

	_, err = database.DB.Exec(`
	UPDATE users 
	SET username = $1, photo_url=$2 
	WHERE id=$3
	`, user.Username, user.PhotoUrl, userID)

	if err != nil {
		JSONError(w, "User not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-type", "application/json")
	w.WriteHeader(http.StatusOK)

	json.NewEncoder(w).Encode(map[string]interface{}{
		"message": "Update success", "status": true},
	)

}

func JSONError(w http.ResponseWriter, message string, status int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	json.NewEncoder(w).Encode(map[string]string{
		"message": message,
	})
}
