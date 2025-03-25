#!/bin/bash

# Connect to database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Get username
echo "Enter your username:"
read username

# Check if user exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$username';")

if [[ -z $USER_ID ]]; then
  # New user
  echo "Welcome, $username! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$username');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$username';")
else
  # Existing user - get stats
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID;")
  echo "Welcome back, $username! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0
GUESSED=false

echo "Guess the secret number between 1 and 1000:"

while ! $GUESSED; do
  read GUESS
  
  # Check if input is integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi
  
  ((GUESS_COUNT++))
  
  if [[ $GUESS -eq $SECRET_NUMBER ]]; then
    GUESSED=true
    # Save game results
    SAVE_GAME=$($PSQL "INSERT INTO games(user_id, guesses, secret_number) VALUES($USER_ID, $GUESS_COUNT, $SECRET_NUMBER);")
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done
