#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"
AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

if [[ -z $AVAILABLE_SERVICES ]]
then
echo "Not available service"
else
echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done

read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
else
SERVICE_PICK=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
SERVICE_PICK_FORMATTED=$(echo $SERVICE_PICK | sed 's/ //g')

  if [[ -z $SERVICE_PICK ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
echo -e "\nI don't have a record for that phone number, what's your name?"
read CUSTOMER_NAME
INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi
echo -e "\nWhat time would you like your $SERVICE_PICK_FORMATTED, $CUSTOMER_NAME?"
read SERVICE_TIME
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ $SERVICE_TIME ]]
then
INSERTED_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
if [[ $INSERTED_APPOINTMENT ]]
then
echo -e "\nI have put you down for a $SERVICE_PICK_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
fi
fi
fi
fi
fi

}

MAIN_MENU 
