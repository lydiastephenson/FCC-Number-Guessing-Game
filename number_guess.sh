#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$((1 + $RANDOM % 1000))

echo -e "\nEnter your username:"
read USERNAME

EXISTING_USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
if [[ -z $EXISTING_USERNAME ]]
then
  USERNAME_LENGTH=${#USERNAME}
  if [ $USERNAME_LENGTH -gt 22 ]
  then
    echo -e "\nPlease enter a username that is less than 22 characters"
  else
    NEW_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  fi
else 
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$EXISTING_USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$EXISTING_USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS
NUMBER_OF_GUESSES=1
echo $SECRET_NUMBER

while [[ $USER_GUESS != $SECRET_NUMBER ]]
do
  if [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then 
    if [ $SECRET_NUMBER -gt $USER_GUESS ]
    then
      echo -e "\nIt's higher than that, guess again:"
      read USER_GUESS
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
    else 
      echo -e "\nIt's lower than that, guess again:"
      read USER_GUESS
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))   
    fi
  else 
    echo -e "\nThat is not an integer, guess again:"
    read USER_GUESS
    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
  fi
done

if [[ -z $GAMES_PLAYED ]]
then
  FIRST_GAME=$($PSQL "UPDATE users SET games_played = 1 WHERE username = '$USERNAME'")
else
  GAME_COUNTER=$($PSQL "UPDATE users SET games_played = (games_played + 1) WHERE username = '$USERNAME'")
fi

if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES < $BEST_GAME ]]
then 
  FIRST_GUESS=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
fi

echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"