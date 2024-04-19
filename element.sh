#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  #search $1 in columns, set other columns value
  if [[ "$1" =~ ^[0-9]+$ ]]
  #separate case to prevent sql error message
  then
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $1")
  fi
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
  NAME=$($PSQL "SELECT name FROM elements WHERE symbol = '$1'")

  #if SYMBOL not empty, i.e. $1 is atomic_number
  if [[ $SYMBOL ]] 
  then
    #set atomic_number and name
    ATOMIC_NUMBER=$1
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $1")

  #if ATOMIC_NUMBER not empty, i.e. $1 is name
  elif [[ $ATOMIC_NUMBER ]]
  then
    NAME=$1
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$1'")

  #if NAME not empty, i.e. $1 is symbol
  elif [[ $NAME ]]
  then 
    SYMBOL=$1
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")
  fi

  #if $1 is none of them
  if [[ -z $NAME ]]
  then
    echo "I could not find that element in the database."
  else
  #set values 
  ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
  MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
  BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
  TYPE=$($PSQL "SELECT type FROM properties LEFT JOIN types USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER")
  #return message
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi