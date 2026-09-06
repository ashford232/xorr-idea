package main

import (
	"log"
	"net/http"
	"os"
	"xorr/internal/database"
	"xorr/internal/handler"
	customMiddlewares "xorr/internal/middleware"
	"xorr/internal/storage"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	dbHost := getEnv("DB_HOST", "localhost")
	dbUser := getEnv("DB_USER", "postgres")
	dbPassword := getEnv("DB_PASSWORD", "xorr")
	dbName := getEnv("DB_NAME", "xorr")
	dbPort := getEnv("DB_PORT", "5432")

	if err := database.InitDB(dbHost, dbUser, dbPassword, dbName, dbPort); err != nil {
		log.Fatalf("Database initialization failed: %v", err)
	}

	r2 := storage.NewR2(
		getEnv("R2_ACCOUNT_ID", ""),
		getEnv("R2_ACCESS_KEY_ID", ""),
		getEnv("R2_SECRET_ACCESS_KEY", ""),
		getEnv("R2_BUCKET", ""),
	)
	handler.R2Storage = r2

	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	r.Post("/register", handler.Signup)
	r.Post("/login", handler.Login)

	r.Group(func(r chi.Router) {
		r.Use(customMiddlewares.Authenticate)
		r.Get("/me", handler.Me)

		r.Post("/me/profile-picture/upload", handler.GetProfileURL)
		r.Put("/users", handler.UpdateUser)

		r.Get("/notes", handler.GetNotes)
		r.Post("/notes", handler.CreateNote)
		r.Put("/notes/{id}", handler.UpdateNote)
		r.Delete("/notes/{id}", handler.DeleteNote)
	})
	port := ":8080"
	log.Println("server running: localhost", port)
	http.ListenAndServe(port, r)
}

func getEnv(key, fallback string) string {
	if val, ok := os.LookupEnv(key); ok {
		return val
	}
	return fallback
}
