package middleware

import (
	"context"
	"net/http"
	"strings"
	"xorr/internal/auth"
)

type contextKey string

const UserIdKey contextKey = "userID"

func Authenticate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")

		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			http.Error(w, "Unauthorised: missing token", http.StatusUnauthorized)
			return
		}

		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
		claims, err := auth.ValidateToken(tokenStr)
		if err != nil {
			http.Error(w, "Unathorized: invalid token", http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(r.Context(), UserIdKey, claims.UserID)
		next.ServeHTTP(w, r.WithContext(ctx))

	})
}
